#!/usr/bin/env python3
"""
EGM (Emeklilik Gozetim Merkezi) rapor toplayici
================================================

Bir EGM istatistik raporunun ust kismindaki tarih listesini gezer ve her tarih
icin "Excel'e Aktar" dugmesine basarak dosyayi indirir.

Kurulum (bir kez):
    pip install playwright
    playwright install chromium

Kullanim:
    # 1) Once KESFET: ne buldugunu yazdirir, hicbir sey indirmez
    python egm_collector.py --url "<rapor linki>" --code GR-01-015 --probe

    # 2) Sonra TOPLA
    python egm_collector.py --url "<rapor linki>" --code GR-01-015 --out data/raw

    # Once birkac tarihle dene:
    python egm_collector.py --url "..." --code GR-01-015 --limit 3 --headful

Notlar:
  * Indirilen dosyalar  <out>/<code>/<code>_<tarih>.xlsx  olarak kaydedilir.
  * Zaten indirilmis tarihler atlanir -> script yarida kesilirse kaldigi
    yerden devam eder.
  * --delay ile istekler arasinda bekleme birakilir. Dusurmeyin; siteyi
    yormayin.
  * EGM verisi EGM A.S.'ye aittir, kaynak gostermeden alinti yapilamaz.
    Toplanan veriyi paylasirken kaynagi belirtin.
"""

from __future__ import annotations

import argparse
import re
import sys
import time
from pathlib import Path

try:
    from playwright.sync_api import TimeoutError as PWTimeout
    from playwright.sync_api import sync_playwright
except ImportError:
    sys.exit("playwright kurulu degil.  pip install playwright && playwright install chromium")


# "30 Eylul 2026 Carsamba" -> "2026-09-30"
AYLAR = {
    "ocak": "01", "subat": "02", "şubat": "02", "mart": "03", "nisan": "04",
    "mayis": "05", "mayıs": "05", "haziran": "06", "temmuz": "07",
    "agustos": "08", "ağustos": "08", "eylul": "09", "eylül": "09",
    "ekim": "10", "kasim": "11", "kasım": "11", "aralik": "12", "aralık": "12",
}


def tarih_slug(metin: str) -> str:
    """Tarih etiketini dosya adina uygun hale getirir."""
    m = re.search(r"(\d{1,2})\s+(\w+)\s+(\d{4})", metin.strip())
    if m:
        gun, ay_adi, yil = m.groups()
        ay = AYLAR.get(ay_adi.lower())
        if ay:
            return f"{yil}-{ay}-{int(gun):02d}"
    # tanimadiysa: guvenli bir sadelestirme
    return re.sub(r"[^0-9A-Za-z]+", "_", metin.strip())[:40]


def tarih_secicisini_bul(page):
    """Sayfadaki tarih <select> ogesini bulur."""
    for sec in page.locator("select").all():
        try:
            if sec.is_visible() and sec.locator("option").count() > 1:
                return sec
        except Exception:
            continue
    return None


def export_dugmesini_bul(page):
    """'Excel'e Aktar' dugmesini birkac yoldan dener."""
    adaylar = [
        page.get_by_title(re.compile(r"Excel", re.I)),
        page.get_by_role("button", name=re.compile(r"Excel", re.I)),
        page.get_by_role("link", name=re.compile(r"Excel", re.I)),
        page.locator("[class*='excel' i]"),
        page.locator("[id*='excel' i]"),
    ]
    for aday in adaylar:
        try:
            if aday.count() > 0 and aday.first.is_visible():
                return aday.first
        except Exception:
            continue
    return None


def main() -> int:
    ap = argparse.ArgumentParser(description="EGM rapor toplayici")
    ap.add_argument("--url", required=True, help="Raporun tam linki")
    ap.add_argument("--code", required=True, help="Rapor kodu, orn. GR-01-015")
    ap.add_argument("--out", default="data/raw", help="Cikti klasoru")
    ap.add_argument("--limit", type=int, default=0, help="Sadece ilk N tarih (0 = hepsi)")
    ap.add_argument("--delay", type=float, default=2.5, help="Tarihler arasi bekleme (sn)")
    ap.add_argument("--timeout", type=int, default=45000, help="Sayfa bekleme suresi (ms)")
    ap.add_argument("--headful", action="store_true", help="Tarayiciyi gorunur ac")
    ap.add_argument("--probe", action="store_true", help="Sadece kesfet, indirme yapma")
    args = ap.parse_args()

    hedef = Path(args.out) / args.code
    hedef.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        tarayici = p.chromium.launch(headless=not args.headful)
        sayfa = tarayici.new_page(accept_downloads=True)
        sayfa.set_default_timeout(args.timeout)

        print(f"Aciliyor: {args.url}")
        sayfa.goto(args.url, wait_until="networkidle")

        secici = tarih_secicisini_bul(sayfa)
        if secici is None:
            print("HATA: tarih listesi bulunamadi.")
            print("  --headful --probe ile acip sayfaya bakin; tarih bir <select>")
            print("  degilse asagidaki tarih_secicisini_bul() fonksiyonunu guncelleyin.")
            tarayici.close()
            return 1

        etiketler = [o.strip() for o in secici.locator("option").all_inner_texts() if o.strip()]
        degerler = secici.locator("option").evaluate_all(
            "els => els.map(e => e.value)"
        )
        print(f"{len(etiketler)} tarih bulundu.  Ilk: {etiketler[0]!r}  Son: {etiketler[-1]!r}")

        dugme = export_dugmesini_bul(sayfa)
        print(f"Excel dugmesi: {'BULUNDU' if dugme else 'BULUNAMADI'}")

        if args.probe:
            print("\n--- ilk 10 tarih ---")
            for e in etiketler[:10]:
                print("  ", e, "->", tarih_slug(e))
            print("\nKesif modu, indirme yapilmadi.")
            tarayici.close()
            return 0

        if dugme is None:
            print("HATA: Excel dugmesi bulunamadi. --headful --probe ile inceleyin.")
            tarayici.close()
            return 1

        isler = list(zip(etiketler, degerler))
        if args.limit:
            isler = isler[: args.limit]

        basarili = atlanan = hatali = 0
        for i, (etiket, deger) in enumerate(isler, 1):
            slug = tarih_slug(etiket)
            dosya = hedef / f"{args.code}_{slug}.xlsx"
            if dosya.exists():
                atlanan += 1
                continue

            print(f"[{i}/{len(isler)}] {etiket} ...", end=" ", flush=True)
            try:
                secici.select_option(value=deger)
                sayfa.wait_for_load_state("networkidle")
                time.sleep(0.8)  # grafigin yeniden cizilmesi icin

                # secim sonrasi DOM yenilenmis olabilir -> dugmeyi tekrar bul
                dugme = export_dugmesini_bul(sayfa) or dugme
                with sayfa.expect_download(timeout=args.timeout) as indirme:
                    dugme.click()
                indirme.value.save_as(dosya)
                print(f"-> {dosya.name}")
                basarili += 1
            except PWTimeout:
                print("ZAMAN ASIMI")
                hatali += 1
            except Exception as hata:
                print(f"HATA: {type(hata).__name__}: {hata}")
                hatali += 1

            time.sleep(args.delay)

        tarayici.close()

    print(f"\nBitti.  indirilen: {basarili}   atlanan: {atlanan}   hatali: {hatali}")
    print(f"Klasor: {hedef.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

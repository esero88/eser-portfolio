#!/usr/bin/env python3
"""
EGM (Emeklilik Gozetim Merkezi) rapor toplayici
================================================

Bir EGM istatistik raporunun ust kismindaki tarih listesini gezer ve her tarih
icin "Excel'e Aktar" dugmesine basarak dosyayi indirir.

Raporun adresi: raporu sitede acip komut cubugundaki zincir ikonuna
("Rapor adresini kopyala") basinca panoya kopyalanir. Sekli soyledir:

    https://egm.org.tr/bilgi-merkezi/istatistikler?r=<uuid>

Kurulum (bir kez):
    pip install playwright
    playwright install chromium

Kullanim:
    # 1) Once KESFET: ne buldugunu yazdirir, hicbir sey indirmez.
    #    Bulamazsa sayfanin yapisini dokerek nedenini gosterir.
    python egm_collector.py --url "<rapor linki>" --code GR-01-015 --probe

    # 2) Sonra TOPLA
    python egm_collector.py --url "<rapor linki>" --code GR-01-015 --out data/raw

    # Once birkac tarihle dene:
    python egm_collector.py --url "..." --code GR-01-015 --limit 3

Notlar:
  * Indirilen dosyalar  <out>/<code>/<code>_<tarih>.xlsx  olarak kaydedilir.
  * Zaten indirilmis tarihler atlanir -> script yarida kesilirse kaldigi
    yerden devam eder.
  * --delay ile istekler arasinda bekleme birakilir. Dusurmeyin.
  * EGM verisi EGM A.S.'ye aittir, kaynak gostermeden alinti yapilamaz.
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


# Sitede dogrulanmis sinif adlari (DevTools, Ekim 2026)
HAZIR_ISARETI = ".egm-report-filter-commands"
EXCEL_SECICILERI = [
    "button.egm-report-to-excel",
    "[title*='Excel' i]",
    "[class*='excel' i]",
]

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
    m = re.search(r"(\d{4})[.\-/](\d{2})[.\-/](\d{2})", metin)
    if m:
        return f"{m.group(1)}-{m.group(2)}-{m.group(3)}"
    return re.sub(r"[^0-9A-Za-z]+", "_", metin.strip())[:40]


def sayfayi_bekle(sayfa, timeout_ms: int) -> None:
    """Rapor komut cubugu gorunene kadar bekler; cikmazsa sabit sure bekler."""
    try:
        sayfa.wait_for_selector(HAZIR_ISARETI, timeout=timeout_ms, state="attached")
        sayfa.wait_for_timeout(1500)  # grafigin cizilmesi
    except PWTimeout:
        sayfa.wait_for_timeout(6000)


def cerceveler(sayfa):
    """Ana sayfa + tum iframe'ler."""
    return [sayfa] + [f for f in sayfa.frames if f != sayfa.main_frame]


AY_DESENI = "|".join(sorted(AYLAR, key=len, reverse=True))


def tarih_gibi(metin: str) -> bool:
    """Bir <option> metni tarih mi?  '30 Eylul 2026', '30.09.2026', '2026-09-30'."""
    m = metin.strip()
    if re.search(rf"\d{{1,2}}\s+({AY_DESENI})\s+\d{{4}}", m, re.I):
        return True
    if re.search(r"\b\d{1,2}[.\-/]\d{1,2}[.\-/]\d{4}\b", m):
        return True
    if re.search(r"\b\d{4}[.\-/]\d{1,2}[.\-/]\d{1,2}\b", m):
        return True
    return False


def select_adaylari(sayfa):
    """Sayfadaki ve iframe'lerdeki tum <select>'leri tarih puaniyla dondurur."""
    adaylar = []
    for ctx in cerceveler(sayfa):
        try:
            secler = ctx.locator("select").all()
        except Exception:
            continue
        for sec in secler:
            try:
                metinler = [t.strip() for t in sec.locator("option").all_inner_texts()]
            except Exception:
                continue
            metinler = [t for t in metinler if t]
            if len(metinler) < 2:
                continue
            puan = sum(tarih_gibi(t) for t in metinler) / len(metinler)
            try:
                sinif = sec.evaluate("e => e.className || ''")
            except Exception:
                sinif = ""
            adaylar.append({"ctx": ctx, "sec": sec, "puan": puan,
                            "n": len(metinler), "ilk": metinler[0][:45],
                            "sinif": str(sinif)[:45]})
    adaylar.sort(key=lambda a: (a["puan"], a["n"]), reverse=True)
    return adaylar


def tarih_secicisini_bul(sayfa, zorla: str | None = None):
    """Secenekleri tarihe benzeyen <select>'i secer."""
    if zorla:
        for ctx in cerceveler(sayfa):
            try:
                aday = ctx.locator(zorla)
                if aday.count() > 0:
                    return ctx, aday.first
            except Exception:
                continue
        return None, None

    adaylar = select_adaylari(sayfa)
    if adaylar and adaylar[0]["puan"] >= 0.5:
        en_iyi = adaylar[0]
        return en_iyi["ctx"], en_iyi["sec"]
    return None, None


def export_dugmesini_bul(sayfa):
    """'Excel'e Aktar' dugmesini arar."""
    for ctx in cerceveler(sayfa):
        for sec in EXCEL_SECICILERI:
            try:
                aday = ctx.locator(sec)
                if aday.count() > 0:
                    return aday.first
            except Exception:
                continue
    return None


def yapiyi_dok(sayfa) -> None:
    """Tarih secici bulunamadiginda sayfada ne oldugunu yazdirir."""
    print("\n--- SAYFA YAPISI ---")
    print("URL   :", sayfa.url)
    try:
        print("BASLIK:", sayfa.title())
    except Exception:
        pass

    ifr = [f for f in sayfa.frames if f != sayfa.main_frame]
    print(f"iframe: {len(ifr)}")
    for f in ifr:
        print("   ", f.url[:110])

    print(f"komut cubugu ({HAZIR_ISARETI}):",
          "VAR" if sayfa.locator(HAZIR_ISARETI).count() else "YOK")

    adaylar = select_adaylari(sayfa)
    print(f"\n{len(adaylar)} adet <select> (tarih puanina gore sirali):")
    for a in adaylar[:8]:
        print(f"   puan={a['puan']:.2f} secenek={a['n']:<4} "
              f"class={a['sinif']!r} ilk={a['ilk']!r}")
    if adaylar:
        print("\n  Tarih kutusu listede ama puani dusukse:")
        print("  --select \"select.<class>\" ile zorlayabilirsiniz.")

    print("\ntarih/filtre gecen ogeler:")
    try:
        bulunan = sayfa.evaluate("""() => {
            const out = [];
            document.querySelectorAll('*').forEach(e => {
                const c = (e.className && e.className.baseVal !== undefined)
                    ? e.className.baseVal : (e.className || '');
                if (typeof c === 'string' &&
                    /(date|tarih|filter|period|donem)/i.test(c) &&
                    out.length < 12) {
                    out.push(e.tagName.toLowerCase() + '.' + c.trim().slice(0, 60));
                }
            });
            return out;
        }""")
        for b in bulunan:
            print("   ", b)
    except Exception as e:
        print("   (okunamadi:", e, ")")
    print("--- SON ---\n")


def main() -> int:
    ap = argparse.ArgumentParser(description="EGM rapor toplayici")
    ap.add_argument("--url", required=True, help="Raporun tam linki (?r=<uuid>)")
    ap.add_argument("--code", required=True, help="Rapor kodu, orn. GR-01-015")
    ap.add_argument("--out", default="data/raw", help="Cikti klasoru")
    ap.add_argument("--limit", type=int, default=0, help="Sadece ilk N tarih (0 = hepsi)")
    ap.add_argument("--delay", type=float, default=2.5, help="Tarihler arasi bekleme (sn)")
    ap.add_argument("--timeout", type=int, default=45000, help="Sayfa bekleme suresi (ms)")
    ap.add_argument("--headful", action="store_true", help="Tarayiciyi gorunur ac")
    ap.add_argument("--probe", action="store_true", help="Sadece kesfet, indirme yapma")
    ap.add_argument("--select", default=None,
                    help="Tarih kutusunu CSS secicisiyle zorla, orn. select.egm-report-date")
    args = ap.parse_args()

    hedef = Path(args.out) / args.code
    hedef.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        tarayici = p.chromium.launch(headless=not args.headful)
        sayfa = tarayici.new_page(accept_downloads=True)
        sayfa.set_default_timeout(args.timeout)

        print(f"Aciliyor: {args.url}")
        sayfa.goto(args.url, wait_until="domcontentloaded")
        sayfayi_bekle(sayfa, args.timeout)

        ctx, secici = tarih_secicisini_bul(sayfa, args.select)
        if secici is None:
            print("HATA: secenekleri tarihe benzeyen bir <select> bulunamadi.")
            yapiyi_dok(sayfa)
            print("Yukaridaki ciktiyi paylasin; secici buna gore duzeltilecek.")
            tarayici.close()
            return 1

        etiketler = [o.strip() for o in secici.locator("option").all_inner_texts() if o.strip()]
        degerler = secici.locator("option").evaluate_all("els => els.map(e => e.value)")
        print(f"{len(etiketler)} tarih bulundu.  Ilk: {etiketler[0]!r}  Son: {etiketler[-1]!r}")

        dugme = export_dugmesini_bul(sayfa)
        print(f"Excel dugmesi: {'BULUNDU' if dugme else 'BULUNAMADI'}")

        if args.probe:
            print("\n--- ilk 10 tarih ---")
            for e in etiketler[:10]:
                print("  ", e, "->", tarih_slug(e))
            if dugme is None:
                yapiyi_dok(sayfa)
            print("\nKesif modu, indirme yapilmadi.")
            tarayici.close()
            return 0

        if dugme is None:
            print("HATA: Excel dugmesi bulunamadi.")
            yapiyi_dok(sayfa)
            tarayici.close()
            return 1

        isler = list(zip(etiketler, degerler))
        if args.limit:
            isler = isler[: args.limit]

        basarili = atlanan = hatali = 0
        for i, (etiket, deger) in enumerate(isler, 1):
            dosya = hedef / f"{args.code}_{tarih_slug(etiket)}.xlsx"
            if dosya.exists():
                atlanan += 1
                continue

            print(f"[{i}/{len(isler)}] {etiket} ...", end=" ", flush=True)
            try:
                secici.select_option(value=deger)
                sayfayi_bekle(sayfa, args.timeout)

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

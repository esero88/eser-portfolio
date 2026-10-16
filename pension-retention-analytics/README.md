# Pension Retention Analytics (BES)

> Çalışma devam ediyor. Bulgular analiz tamamlandıkça bu README'ye eklenecek.

**Soru:** Türkiye bireysel emeklilik sisteminde sözleşmeler ne kadar süre yaşıyor, neden
sonlanıyor, ve bu tabloda tek tek şirketler nerede duruyor?

**Araçlar:** Python (Playwright, pandas), PostgreSQL, Tableau, RAG tabanlı doğal dil → SQL agent

**Veri kaynağı:** [Emeklilik Gözetim Merkezi (EGM)](https://www.egm.org.tr/) — Bilgi Merkezi > İstatistikler

---

## Proje ne yapacak

1. EGM'nin yayınladığı BES istatistik raporlarını tarih tarih toplar.
2. Çok satırlı başlıkları ve dağınık formatları temizleyip analiz edilebilir hale getirir.
3. Temiz tabloları bir PostgreSQL ambarına yükler.
4. Sözleşme kalıcılığını, sonlanma nedenlerini ve şirketlerin rekabet konumunu
   Tableau'da görselleştirir.
5. Doğal dilde sorulan iş sorularını metrik sözlüğüne sadık SQL'e çeviren bir agent kurar.
6. Agent'ı 30 soruluk bir test setiyle ölçer, doğruluk ve hata türlerini tabloya döker.

---

## Veri katmanları

Proje iki veri katmanı üzerine kurulu. Ayrım bilinçli ve README'de açıkça duruyor:

| Katman | Kaynak | Kullanım |
|---|---|---|
| **Gerçek** | EGM istatistik raporları (agregat) | Dashboard — kalıcılık, sonlanma nedenleri, pazar payı, maliyet |
| **Simüle** | Gerçek agregatlara kalibre edilmiş sentetik katılımcı/sözleşme tabloları | SQL agent'ın test ortamı |

Simüle katman neden gerekli: EGM verisi agregat seviyede yayınlanıyor, katılımcı
seviyesinde değil. Doğal dilden SQL üreten bir agent'ı test etmek için join yapılabilir,
grain'i ince bir ambar gerekiyor. Bu katmanın marjinal dağılımları ve iş kuralları
gerçek EGM agregatlarına tutturulacak — rastgele üretim değil, kalibre simülasyon.

**Dashboard'daki hiçbir bulgu simüle veriden gelmeyecek.**

---

## Toplanacak raporlar

| Kod | Rapor | Ne için |
|---|---|---|
| `GR-01-015` | Sözleşmelerin Yürürlüğe Giriş Ayına Göre Sonlanma Oranı | Aylık kohort retention eğrisi |
| `GR-01-010` | Sonlanan Sözleşmelerin Sonlanma Nedenine Göre Dağılımı | Ayrılma nedeni kırılımı |
| `GR-01-019` | Cayma Hakkı Kullanım Oranı | Cayma trendi |
| `GR-01-018` | Şirketler Arası Aktarım — önceki şirkette geçirilen süre | Şirket değiştirme davranışı |
| `GR-01-116` | Giriş Yıllarına Göre Sonlanma ve Tahsilat Oranları (Sektör) | Kohort tahsilat |
| `EGM-05-006` | Emeklilik Şirketi ve Faiz Detayında Fon Büyüklükleri | Şirket bazında pazar payı |
| `EGM-05-001` | Fon Bazında Fon İşletim Gideri Kesinti Oranları | Maliyet rekabeti |
| `EGM-05-012` | Emeklilik Yatırım Fonları Listesi | Fon → şirket eşlemesi |

Kontrol edilecek: `GR-01-*` raporlarının hangileri şirket kırılımı içeriyor, hangileri
sektör toplamı. Şirket bazlı karşılaştırmanın kapsamı buna göre netleşecek.

---

## Klasör yapısı

```
pension-retention-analytics/
├── notebooks/     # veri toplama, temizleme, analiz defterleri
├── scripts/       # yeniden kullanılabilir Python modülleri
├── tableau/       # .twb çalışma kitapları
└── data/          # ham ve temiz veri — git'e DAHİL DEĞİL (.gitignore)
    ├── raw/
    └── clean/
```

`data/` neden commit edilmiyor: EGM verileri Emeklilik Gözetim Merkezi A.Ş.'ye ait.
Repo'da veriyi değil, veriyi üreten kodu tutuyoruz. Toplayıcıyı çalıştıran herkes
aynı veriye kaynağından ulaşabilir.

---

## Kurulum

```bash
pip install playwright pandas openpyxl
playwright install chromium
```

## Veri toplama

```bash
# Önce keşif — indirme yapmaz, sadece sayfada ne bulduğunu söyler
python scripts/egm_collector.py --url "<rapor linki>" --code GR-01-015 --probe

# Sonra toplama
python scripts/egm_collector.py --url "<rapor linki>" --code GR-01-015 --out data/raw
```

Colab'da çalışmak için: `notebooks/01_egm_veri_toplama.ipynb`

---

## Yol haritası

- [ ] EGM raporlarının toplanması
- [ ] Temizlik: çok satırlı başlıkların düzleştirilmesi, uzun formata çevirme
- [ ] PostgreSQL ambarı — yıldız şema
- [ ] Metrik sözlüğü (kalıcılık, cayma oranı, net akış tanımları)
- [ ] Tableau dashboard + Tableau Public yayını
- [ ] Simüle katılımcı katmanı (gerçek agregatlara kalibre)
- [ ] RAG tabanlı doğal dil → SQL agent
- [ ] 30 soruluk doğruluk testi ve hata analizi

---

## Kaynak

Bu projede kullanılan tüm istatistiksel veriler **Emeklilik Gözetim Merkezi A.Ş. (EGM)**'ye
aittir. Kaynak gösterilmeden alıntı yapılamaz. https://www.egm.org.tr/

---

**Eser Karaceper** — Tableau | SQL | Python | Data Modeling

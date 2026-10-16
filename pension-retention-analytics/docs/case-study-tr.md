# Vaka Çalışması: BES'te sözleşmeler neden yaşamıyor?

## Giriş

Bu vaka çalışmasında bir emeklilik şirketinin analitik ekibinde çalışıyorsun ve tek bir soruyu cevaplıyorsun: bireysel emeklilik sözleşmeleri neden yaşamıyor, şirketin bu tabloda yeri ne?

İş sorularını cevaplamak için veri analizi sürecinin altı adımını izleyeceksin: **Sor, Hazırla, İşle, Analiz Et, Paylaş, Harekete Geç**. Her adımın sonunda bir Yol Haritası tablosu var — yönlendirici sorular, temel görevler ve o adımın teslimatı. Yolu kaybettiğinde o tablolara dön.

Google'ın Cyclistic ve Bellabeat vaka çalışmalarından iki farkı var:

1. **Veri gerçek.** Cyclistic ve Bellabeat kurgu şirketler, verileri de vekil veri. Burada şirket kurgu ama veri gerçek: Emeklilik Gözetim Merkezi'nin (EGM) yayınladığı kamuya açık BES istatistikleri. Bulgular gerçek sektörü anlatıyor.
2. **Üstüne bir katman daha var.** Klasik analiz bittikten sonra, iş kullanıcısının Türkçe sorduğu soruyu SQL'e çeviren bir agent kuruyor ve 30 soruluk bir testle kaç tanesini doğru cevapladığını ölçüyorsun. Bu kısım portfolyoda projeyi sıradan bir dashboard çalışmasından ayıran şey.

Bitirdiğinde elinde portfolyoya konulabilir bir vaka çalışması, bir Tableau dashboard'u ve ölçülmüş bir AI agent'ı olacak.

## Senaryo

Anka Emeklilik ve Hayat A.Ş.'nin analitik ekibinde veri analistisin. Anka orta ölçekli bir şirket: yaklaşık 750 bin katılımcısı var ama fon büyüklüğünde sektör payı %1,5 civarında. Yani insan çok, para az.

Pazarlama ve Müşteri'den sorumlu Genel Müdür Yardımcısı Deniz Arslan, yıllık strateji toplantısı öncesi şu tespiti yapıyor: şirket her yıl yeni sözleşme kazanıyor ama toplam portföy beklenen hızda büyümüyor. Kazanılanın bir kısmı arka kapıdan çıkıyor. Hangi kapıdan, ne zaman ve neden çıktığını kimse net bilmiyor.

Deniz senden sektörün kamuya açık verisini kullanarak bu soruyu cevaplamanı istiyor. Anka'nın kendi müşteri verisi bu analizin kapsamında değil — önce sektörün genel davranışını anlamak, sonra şirketin nerede durduğunu görmek istiyor. Bulguları icra kuruluna sunacak, o yüzden hem görsel hem savunulabilir olmalı.

> **Not:** Anka Emeklilik kurgu bir şirkettir. Vaka çalışmasına bir iş bağlamı ve paydaş vermek için uyduruldu. Kullanılan tüm veriler gerçek ve kamuya açıktır; analizde geçen şirket isimleri (AgeSA, Anadolu Hayat, Garanti, Allianz vb.) EGM raporlarında yayınlandığı şekliyle gerçek şirketlerdir.

## Karakterler ve ekipler

| Kişi / ekip | Rolü | Senden beklediği |
| --- | --- | --- |
| **Deniz Arslan** | Genel Müdür Yardımcısı, Pazarlama ve Müşteri — senin yöneticin | Sözleşmelerin neden sonlandığına dair net bir cevap ve icra kuruluna sunulabilir görseller |
| **Analitik ekibi** | Veri toplama, modelleme ve raporlama. Altı aydır bu ekiptesin | Tekrarlanabilir bir veri hattı — analiz bir kez değil, her çeyrek yenilenebilmeli |
| **Aktüerya ekibi** | Fon ve teminat hesaplarının sahibi | Metrik tanımlarının kendi hesaplarıyla çelişmemesi |
| **İcra kurulu** | Pazarlama bütçesinin onay merci | Tavsiyelerin rakamla desteklenmesi |

Metrik tanımları bu vaka çalışmasının sessiz zorluğu. "Aktif katılımcı", "kalıcılık", "kayıp" gibi terimlerin hiçbiri bir veri kolonunda yazmıyor; her biri bir iş kararı. En tartışmalısı "aktif katılımcı" — bir sonraki bölümde açılıyor. Aktüerya ekibiyle aynı tanımı kullanmazsan aynı veriden iki farklı rakam çıkar.

## Sektör hakkında

BES'i anlamadan verisini okuyamıyorsun. Analizi şekillendiren mekanizmalar bunlar.

**İki ayrı sistem var.** Gönüllü BES'e kişi kendi isteğiyle girer ve katkı payını kendi belirler. Otomatik Katılım'da (OKS) çalışan işvereni aracılığıyla sisteme otomatik dahil edilir; katkı payı primine esas kazancının %3'üdür ve belirli bir süre içinde cayma hakkını kullanıp çıkabilir. İki sistemin davranışı bambaşka — analizde ayrı tutman gerekiyor.

**Devlet katkısı sistemin çimentosu, ve 2026'da değişti.** Katılımcının yatırdığı her 100 TL'ye devlet ek katkı yapar. Bu oran yıllardır %30'du; 7 Ocak 2026'da Resmî Gazete'de yayımlanan Cumhurbaşkanı kararıyla **%20'ye indi** ([kaynak](https://medyascope.tv/2026/01/07/beste-devlet-katkisi-yuzde-30dan-yuzde-20ye-indi/)). Mevcut birikimler korundu, yeni katkılar yeni oran üzerinden işliyor. Veri setin bu tarihi kapsıyorsa, kalıcılık eğrisinde bir kırılma arama ihtimalin var.

**Devlet katkısı hemen senin olmuyor — kıdemle hak ediliyor.** Sistemde geçirilen süreye göre ([kaynak](https://www.agesa.com.tr/bes/sss)):

| Sistemde geçen süre | Hak edilen devlet katkısı |
| --- | --- |
| 3 yıl+ | %15 |
| 6 yıl+ | %35 |
| 10 yıl+ | %60 |
| 10 yıl+ ve 56 yaş | Tamamı |

Bu tablo analizin kalbi. Erken ayrılan katılımcı devlet katkısının büyük kısmını bırakıp gidiyor — yani ayrılma hem katılımcı hem şirket için kayıp. Teorik olarak insanı sistemde tutması gereken bir teşvik var; buna rağmen ayrılıyorlarsa, nedenini bulmak asıl mesele.

**Sözleşme yedi farklı şekilde sonlanıyor.** EGM bunları ayrı ayrı raporluyor: sistemden çıkış, cayma, başka şirkete aktarım, emeklilik, hesap birleştirme, vefat/maluliyet, red/fesih. Bunların hepsi "sonlanma" başlığı altında toplanıyor ama iş anlamları taban tabana zıt: emeklilik başarı, başka şirkete aktarım rekabet kaybı, sistemden çıkış gerçek kayıp. Hepsini tek bir "churn" rakamına indirgersen analiz anlamını kaybeder.

Bu ayrımı doğru kurmak, bu vaka çalışmasının başarı ölçütü.

## 1. Sor

Üç soru analizi yönlendirecek:

1. Sözleşmeler ne kadar yaşıyor — giriş kohortuna göre sonlanma oranı nasıl değişiyor?
2. Sonlanmaların ne kadarı gerçek kayıp, ne kadarı başarı ya da rekabet kaybı?
3. Anka fon büyüklüğü ve maliyet rekabetinde nerede duruyor?

Deniz birincisini asli soru olarak işaretledi: **sözleşmeler ne kadar yaşıyor ve neden sonlanıyor?** Diğer ikisi bu cevabı bağlama oturtuyor.

Altı teslimat üreteceksin:

1. İş görevinin net bir tanımı
2. Kullanılan tüm veri kaynaklarının açıklaması
3. Veri temizleme ve dönüştürme adımlarının dokümantasyonu
4. Analizin özeti
5. Destekleyici görselleştirmeler ve temel bulgular
6. Analize dayalı üç öneri

### Hangi kararı değiştiriyoruz?

Emeklilik şirketlerinde yıllık pazarlama bütçesinin büyük kısmı **yeni sözleşme kazanımına** gider: bankasüransta şube hedefleri, kampanyalar, hediye çekleri. Kazanım ölçülebilir ve hızlıdır — ay sonunda kaç yeni sözleşme kurulduğu bellidir. Kalıcılık ise geç görünür ve ölçümü tartışmalıdır. Bu asimetri yüzünden bütçe kazanıma akar.

Deniz'in cevaplamak istediği karar şu: **bütçenin bir kısmı kazanımdan kalıcılığa kaydırılmalı mı?** Analizin gerçekten değiştirebileceği karar bu.

### Tartışmalı metrik: "aktif katılımcı"

Sektörde en çok tartışılan tanım bu, ve sebebi mevzuatta.

BES'te katkı payı ödemesine ara verilebilir. Ödeme vadesinden itibaren üç ay içinde yapılmazsa sözleşme "ara verilmiş" sayılır — ama **sistemden çıkmış sayılmaz** ([kaynak](https://www.turkiyegazetesi.com.tr/tasarruf-ortagim/bes-odemelerine-ara-verilebilir-mi-beste-5-yil-siniri-1822478)). Sözleşme yürürlükte kalır, birikim fonlarda işlemeye devam eder, katılımcı hâlâ katılımcıdır.

Yani bir şirket "750 bin katılımcımız var" diyebilir ve bunların önemli bir kısmı yıllardır hiç para yatırmıyor olabilir. İki tanım çarpışıyor:

| Tanım | Ne sayıyor | Kimin işine yarıyor |
| --- | --- | --- |
| **A — Yürürlükte** | Sözleşmesi sonlanmamış herkes | Kazanım hedefleri, basın bülteni, pazar payı |
| **B — Ödeme yapan** | Son 12 ayda katkı payı girmiş sözleşmeler | Fon büyümesi, gerçek portföy değeri |

Aynı şirket için bu iki rakam çok farklı çıkar. Hangisini kullandığın bütçe kararını doğrudan değiştirir: A tanımıyla bakınca şirket büyüyor görünür, B tanımıyla bakınca portföyün ne kadarının ölü olduğu çıkar.

Buna bağlı ikinci bir tanım sorunu var: EGM "sonlanma" başlığı altında emekliliği de, caymayı da, başka şirkete aktarımı da sayar. Bunları tek bir "kayıp" rakamına indirgemek analizi anlamsız kılar.

**Kararı kim veriyor:** Bütçeyi icra kurulu onaylıyor. Ama metrik tanımının sahibi aktüerya ekibi. Sunumdan önce tanımı aktüeryayla mutabık kalmazsan toplantı analizi değil tanımı tartışmakla geçer — bu vaka çalışmasının en gerçekçi tuzağı.

**Kapsam uyarısı:** EGM'nin kamuya açık raporları sözleşme sonlanmalarını veriyor. Ödemeye ara verme konusunda ne yayınlandığını "Katkı Payı" klasöründe (20 rapor) kontrol et. Oradan çıkmazsa B tanımını sektör verisiyle hesaplayamazsın — bunu kısıt olarak yaz ve Harekete Geç bölümünde "şirketin kendi verisiyle bir sonraki adım" diye öner.

| Yol Haritası — Sor | |
| --- | --- |
| **Yönlendirici sorular** | Çözmeye çalıştığın problem ne? Bulguların hangi iş kararını değiştirecek? Hangi metriğin tanımı tartışmalı ve kim karar verecek? |
| **Temel görevler** | İş görevini tanımla. Paydaşları ve her birinin kararını belirle. "Sonlanma" ile "kayıp" arasındaki farkı netleştir. |
| **Teslimat** | İş görevinin net bir tanımı |

**İpucu:** İş görevini yazarken "BES verisini analiz etmek" gibi bir cümle kurma — bu görev değil, faaliyet. Görev, cevaplanacak soruyu ve kimin ne kararı için cevaplandığını içermeli.

## 2. Hazırla

Veri [Emeklilik Gözetim Merkezi'nin](https://www.egm.org.tr/) Bilgi Merkezi > İstatistikler bölümünde. 250'den fazla rapor var; hepsi Excel olarak indirilebiliyor ve her rapor üstteki tarih listesinden seçilen bir ana ait.

Toplayacağın raporlar:

| Kod | Rapor | Neyi cevaplıyor |
| --- | --- | --- |
| `GR-01-015` | Sözleşmelerin Yürürlüğe Giriş Ayına Göre Sonlanma Oranı | Kohort kalıcılık eğrisi — asli soru |
| `GR-01-010` | Sonlanan Sözleşmelerin Sonlanma Nedenine Göre Dağılımı | Ayrılma nedenleri |
| `GR-01-019` | Cayma Hakkı Kullanım Oranı | Erken çıkış |
| `GR-01-018` | Şirketler Arası Aktarım — önceki şirkette geçirilen süre | Rekabet kaybı |
| `GR-01-014` | Kıdeme Göre Sözleşmelerin Dağılımı | Devlet katkısı hak edişiyle karşılaştırma |
| `GR-01-116` | Giriş Yıllarına Göre Sonlanma ve Tahsilat Oranları (Sektör) | Kohort tahsilat |
| `EGM-05-006` | Emeklilik Şirketi ve Faiz Detayında Fon Büyüklükleri | Şirket bazında pazar payı |
| `EGM-05-001` | Fon Bazında Fon İşletim Gideri Kesinti Oranları | Maliyet rekabeti |

**Önce kontrol et:** Bu raporların hangileri şirket kırılımı içeriyor, hangileri sektör toplamı? Başlığında "(Sektör)" yazan var, yazmayan ama yine de toplam olan var. Bu ayrım analizin kapsamını belirliyor — kalıcılık sektör seviyesinde kalırsa "Anka'nın kalıcılığı rakiplerden iyi mi" sorusunu soramazsın, soruyu yeniden çerçevelemen gerekir.

### Veri ROCCC mu?

| Ölçüt | Değerlendirme |
| --- | --- |
| **Reliable** (güvenilir) | **Güçlü.** Düzenleyici gözetim kurumu; şirketlerin bildirim yükümlülüğü var |
| **Original** (birincil) | **Güçlü.** Şirketlerin EGM'ye bildirdiği veriden üretiliyor, ikincil derleme değil |
| **Comprehensive** (kapsamlı) | **Zayıf.** Veri agregat — katılımcı davranışı modellenemiyor. Hangi raporda şirket kırılımı olduğu baştan belli değil. Ödemeye ara verme verisi yayınlanıyor mu, doğrulanmadı |
| **Current** (güncel) | **Güçlü.** Düzenli yenileniyor; her rapor seçilen tarihe ait |
| **Cited** (atıflı) | **Koşullu.** Atıf zorunlu, kaynak gösterilmeden alıntı yapılamıyor |

**Önemli sınırlama:** EGM verisi **agregat**, katılımcı seviyesinde değil. "Hangi katılımcı ayrılır" sorusunu bu veriyle modelleyemezsin; ancak "hangi kohort, hangi kıdemde, hangi nedenle" sorusunu cevaplayabilirsin. Bu sınırı vaka çalışmasında açıkça yaz — veriyle yapılamayacak şeyi bilmek, yapılabileni bilmek kadar değerli.

**Lisans ve atıf:** EGM raporlarının altında "Bu raporda yer alan tüm istatistiksel veriler, grafikler ve analizler Emeklilik Gözetim Merkezi A.Ş.'ye (EGM) aittir. Kaynak gösterilmeden alıntı yapılamaz" notu var. Atıf hem README'de hem **dashboard'un üzerinde** görünür olmalı — Tableau Public'te dashboard'u gören kişi README'yi görmüyor.

**Gizlilik:** Veri agregat olduğu için kişisel veri içermiyor. Bu, çalışmanın avantajı — KVKK kapsamında bir risk taşımıyorsun.

| Yol Haritası — Hazırla | |
| --- | --- |
| **Yönlendirici sorular** | Veri nerede ve nasıl organize edilmiş? Önyargı veya güvenilirlik sorunu var mı? Veri ROCCC mu? Lisans, gizlilik ve erişilebilirliği nasıl ele alıyorsun? Soruyu cevaplamaya yetiyor mu, nerede yetmiyor? |
| **Temel görevler** | Raporları indir ve düzenli sakla. Hangi raporda şirket kırılımı var tespit et. Veri bütünlüğünü doğrula. Kapsam sınırlarını yazıya dök. |
| **Teslimat** | Kullanılan tüm veri kaynaklarının açıklaması |

## 3. İşle

EGM'den inen Excel dosyaları doğrudan analiz edilebilir değil. Üç sorun var: başlıklar iki satıra bölünmüş (örneğin `EGM-05-006`'da üst satır "Gönüllü BES", alt satır "Faizli/Faizsiz"), büyük sayılar bilimsel gösterime düşüyor, ve her dosya tek bir aya ait — zaman serisi için birleştirmen gerekiyor.

**Adımlar:**

1. **Topla.** `scripts/egm_collector.py` raporun tarih listesini gezer, her tarih için "Excel'e Aktar"a basar, `KOD_YYYY-AA-GG.xlsx` olarak kaydeder. Önce `--probe` ile çalıştır — indirme yapmadan tarih listesini ve düğmeyi bulup bulmadığını söyler.
2. **Başlıkları düzleştir.** İki satırlık başlığı tek satıra indir: `gonullu_bes_faizli`, `oks_faizsiz` gibi. snake_case kullan, Türkçe karakter bırakma — SQL'de başını ağrıtır.
3. **Türleri düzelt.** Tutarları `numeric`e, oranları `numeric`e, tarihleri `date`e çevir. Bilimsel gösterimden gelen hassasiyet kaybını kontrol et.
4. **Uzun formata çevir.** Geniş tabloları `rapor_tarihi, şirket, segment, metrik, değer` şeklinde uzun formata al. Hem SQL hem Tableau bu formatı sever.
5. **Birleştir.** Aylık dosyaları tek tabloda topla, `rapor_tarihi` kolonuyla.
6. **Doğrula.** Her rapor tarihi için genel toplam, şirket toplamlarının toplamına eşit mi? EGM'nin kendi "Genel Toplam" satırıyla karşılaştır. Tutmuyorsa dönüştürmede hata var.
7. **Yükle.** Temiz tabloları PostgreSQL'e al, yıldız şema kur: `fact_fon_buyuklugu`, `fact_sozlesme_sonlanma`, `dim_sirket`, `dim_tarih`, `dim_sonlanma_nedeni`.

**Dokümantasyon kuralı:** Her temizlik kararını defterde yorum olarak yaz. "Neden bu kolonu attım", "neden bu satırı dışarda bıraktım" — üç ay sonra kendin de hatırlamazsın, işe alım görüşmesinde ise tam bunu sorarlar.

**Araç seçimi ve gerekçesi:**

| Araç | Nerede | Neden |
| --- | --- | --- |
| Python (Playwright) | Toplama | EGM sayfası JavaScript ile çiziliyor; `requests` boş tablo getirir |
| Python (pandas) | Temizleme | Çok satırlı başlık ve geniş→uzun dönüşümü için en pratik |
| PostgreSQL | Ambar | Agent'ın sorgulayacağı katman; ayrıca şema disiplini getiriyor |
| Tableau | Dashboard | Portfolyoda Tableau Public linki paylaşılabiliyor |

| Yol Haritası — İşle | |
| --- | --- |
| **Yönlendirici sorular** | Hangi araçları neden seçtin? Veri bütünlüğünü nasıl sağladın? Temiz olduğunu nasıl doğruladın? Temizlik sürecini paylaşılabilecek şekilde belgeledin mi? |
| **Temel görevler** | Hataları kontrol et. Araçları seç. Veriyi çalışılabilir hale dönüştür. Temizlik sürecini belgele. |
| **Teslimat** | Veri temizleme ve dönüştürme adımlarının dokümantasyonu |

## 4. Analiz Et

Veri hazır; şimdi soruyu cevaplama zamanı. Dört analiz hattı var.

### A. Kohort kalıcılık eğrisi — asli analiz

`GR-01-015` her giriş ayı için iki şey veriyor: o ay kaç sözleşme kuruldu, ve bugün itibarıyla ne kadarı sonlanmış. 2003'ten bugüne aylık, yani ~275 kohort.

Dikkat edilecek nokta: eski kohortların sonlanma oranı doğal olarak yüksek çıkar — daha uzun süre maruz kalmışlar. Ham oranları yan yana koyarsan 2004 kohortunun 2024'ten kötü olduğu gibi yanlış bir sonuç çıkar. Karşılaştırmayı **eşit kıdemde** yap: her kohortun ilk 12 ayındaki, 24. ayındaki sonlanma oranı.

Aranacak şeyler: kalıcılık yıllar içinde iyileşiyor mu? Mevzuat değişikliklerinde (OKS'nin başlaması, devlet katkısı oran değişiklikleri) kırılma var mı? Devlet katkısı hak ediş eşikleri (3, 6, 10 yıl) eğride görünüyor mu — insanlar eşiği geçmeyi bekliyor mu?

### B. Sonlanma nedenleri

`GR-01-010` sonlanmaları yedi nedene ayırıyor. Bunları üç iş kategorisine indir:

| Kategori | Nedenler | Şirket için anlamı |
| --- | --- | --- |
| Gerçek kayıp | Sistemden çıkış, cayma, red/fesih | Önlenebilir — asıl hedef |
| Rekabet kaybı | Başka şirkete aktarım | Önlenebilir — ama farklı bir müdahale gerektirir |
| Kayıp değil | Emeklilik, vefat/maluliyet, hesap birleştirme | Önlenemez veya zaten başarı |

Bu ayrımı yapmadan hesaplanan her "churn" rakamı yanıltıcıdır.

### C. Rekabet konumu

`EGM-05-006` fon büyüklüğünü şirket bazında veriyor. Hesaplanacaklar: Anka'nın gönüllü BES ve OKS payları, pazar yoğunlaşması (ilk dört şirket toplamın ne kadarını tutuyor), ve zaman içinde payların değişimi. Faizli/faizsiz ayrımı da var — katılım emekliliği tercihi şirketler arasında çok farklı dağılıyor, bu kendi başına bir bulgu olabilir.

### D. Maliyet

`EGM-05-001` fon işletim gideri kesinti oranlarını veriyor. Soru: yüksek kesinti oranı olan şirketler katılımcı kaybediyor mu? Bu bir korelasyon arıyor, nedensellik iddia etme.

**Sürpriz aramayı unutma.** Vaka çalışmasını ezber bir rapordan ayıran şey, beklenmedik bulgudur. Veriye "şunu doğrulayayım" diye değil, "burada ne var" diye bak.

| Yol Haritası — Analiz Et | |
| --- | --- |
| **Yönlendirici sorular** | Veriyi analiz için nasıl organize etmelisin? Sürpriz ne buldun? Hangi trend ve ilişkiler çıktı? Bu bulgular iş sorusunu nasıl cevaplıyor? |
| **Temel görevler** | Veriyi anlamlı şekilde toplulaştır. Hesaplamaları yap. Eşit kıdemde karşılaştır. Trend ve ilişkileri belirle. |
| **Teslimat** | Analizin özeti |

## 5. Paylaş

Deniz bulguları icra kuruluna sunacak. Görseller hem rafine hem kendi kendini açıklayan olmalı — yanında sen olmadan da anlatılmalı.

**Dashboard'un taşıyacağı dört görsel:**

1. **Kohort kalıcılık eğrisi** — kıdeme göre hayatta kalma. Her kohort bir çizgi ya da ısı haritası; x ekseni kıdem ayı, giriş tarihi değil.
2. **Sonlanma nedenleri** — üç iş kategorisine göre. Pasta grafikten kaçın; yığılmış çubuk zamanla değişimi de gösterir.
3. **Pazar payı** — Anka'nın konumu ve yoğunlaşma. Sıralı çubuk yeter.
4. **Maliyet vs kalıcılık** — kesinti oranıyla kayıp arasında ilişki var mı? Saçılım grafiği.

**Tableau Public kısıtı:** Tableau Public canlı veritabanı bağlantısı desteklemiyor. PostgreSQL'e bağlanıp yayınlayamazsın — temiz tabloları CSV olarak çıkarıp Tableau'yu onların üzerine kur. Ambar yine de kuruluyor; agent'ın çalışacağı yer orası.

**Atıf:** EGM kaynağını dashboard'un üzerine yaz. Tableau Public'te çalışmanı gören kişi GitHub README'sini görmüyor.

**Görsel ilkeler:** Kontrastı en önemli bulguyu işaret etmek için kullan. Başlık bulguyu söylesin, grafiğin türünü değil — "Sonlanma oranı kohort bazında" değil, "Yeni kohortlar ilk yılı daha iyi geçiriyor". Eksenlerde birim yaz. Renk tek başına anlam taşımasın.

| Yol Haritası — Paylaş | |
| --- | --- |
| **Yönlendirici sorular** | Sözleşmelerin neden sonlandığı sorusunu cevaplayabildin mi? Verin hangi hikayeyi anlatıyor? Hedef kitlen kim ve onlara en iyi nasıl ulaşırsın? Görselleştirme yardımcı oluyor mu? |
| **Temel görevler** | Bulguları paylaşmanın en iyi yolunu belirle. Etkili görseller oluştur. Kaynağı görünür kıl. Erişilebilirliği sağla. |
| **Teslimat** | Destekleyici görselleştirmeler ve temel bulgular |

## 6. Harekete Geç

Deniz'in istediği üç öneriyi hazırla. İyi bir öneri üç şeyi taşır: hangi bulguya dayandığı, kimin ne yapacağı, ve başarının nasıl ölçüleceği.

**Kendine sor:** Bulgular bir pazarlama bütçesi kararını gerçekten değiştirir mi? "Kalıcılığı artırmalıyız" bir öneri değil, temenni. "İlk 12 ayını dolduran katılımcıların ayrılma oranı keskin düşüyor, bu yüzden ilk yıl temas programına bütçe kaydırılmalı" bir öneridir.

**Sınırlarını da yaz.** EGM verisi agregat; katılımcı bazında kimin ayrılacağını tahmin edemezsin. Bir sonraki adımın ne olduğunu söyle: şirketin kendi CRM verisiyle katılımcı seviyesinde model. Analizin nerede bittiğini bilmek, güvenilirliğini artırır.

**Portfolyoya ekleme:**

1. `pension-retention-analytics` klasöründeki README'ye "Key findings" bölümünü ekle — rakamlarla.
2. Tableau Public'e dashboard'u yayınla, linkini README'ye koy.
3. Dashboard ekran görüntüsünü README'nin başına koy — diğer projelerinde yaptığın gibi.
4. Kök README'de 6. projenin "Result" satırını güncelle.
5. LinkedIn için bir yazı çıkar: en çarpıcı tek bulgu + nasıl bulduğun.

| Yol Haritası — Harekete Geç | |
| --- | --- |
| **Yönlendirici sorular** | Analizine dayanan nihai sonucun ne? Ekip ve işletme bu içgörüleri nasıl uygular? Paydaşlar hangi adımı atmalı? Bulguları genişletmek için hangi ek veri gerekir? |
| **Temel görevler** | Üç öneriyi yaz. Sınırları belirt. Vaka çalışmasını portfolyoya ekle. Sunumunu prova et. |
| **Teslimat** | Analize dayalı üç öneri |

## Ek: Agentic AI katmanı

Buraya kadar olan kısım Google'ın vaka çalışmalarıyla aynı iskelette. Bu bölüm ekstra — ve portfolyoda farkı yaratan kısım.

**Problem:** Deniz her soru için sana geliyor. "At Risk kohortta kaç sözleşme var", "geçen çeyrek cayma oranı ne oldu" — hepsi ticket oluyor, cevap bir gün sürüyor. Çözüm: doğal dildeki soruyu SQL'e çeviren bir asistan.

### 1. Simüle katılımcı katmanı

EGM verisi agregat; SQL agent'ını test etmek için join yapılabilir, grain'i ince bir ambar gerekiyor. Bunun için katılımcı ve sözleşme seviyesinde sentetik tablolar üretiyorsun — ama rastgele değil: yaş dağılımı, kıdem dağılımı, sonlanma nedenleri ve oranları gerçek EGM agregatlarına tutturuluyor.

İki şeyi karıştırma: LLM'e "10.000 müşteri üret" dedirtmek uydurmadır ve işe yaramaz — dashboard'da gördüğün her örüntüyü modelin kendisi koymuş olur. Kalibre simülasyon farklı: marjinalleri ve iş kuralları yayınlanmış gerçek rakamlara çapalanır. Aktüerler model testi için bunu zaten yapar.

**Kural:** Dashboard'daki hiçbir bulgu simüle veriden gelmez. Bu ayrım README'de ve vaka çalışmasında açıkça yazılır.

### 2. Metrik sözlüğü

Agent'ın okuyacağı tanım dosyası. Her metrik için: tanım, hesaplama kuralı, hangi tabloda, sınırları. Örneğin "kalıcılık" — hangi sonlanma nedenleri sayılıyor, referans tarih bugün mü veri setinin son tarihi mi? "Aktif katılımcı" — A tanımı mı B tanımı mı?

Bu dosya projenin en değerli parçası. Agent'ı akıllı yapan şey model değil, bu sözlükteki tanımlar.

### 3. 30 soruluk doğruluk testi

Agent kurulduktan sonra "çalışıyor" demek yetmez. 30 soru hazırla, her biri için kendi elinle doğru SQL'i yaz (gold SQL), sonra agent'ı çalıştır ve karşılaştır.

| Zorluk | Adet | İçerik |
| --- | --- | --- |
| Kolay | 10 | Tek tablo, filtre ve toplama |
| Orta | 10 | Join, oran hesabı, tarih mantığı |
| Zor | 7 | Window function, dönem karşılaştırma, iç içe metrik |
| Cevaplanmamalı | 3 | Veride olmayan şey — agent "bilmiyorum" diyebilmeli |

Son satır önemli: doğru SQL üretmek kadar, **üretememesi gereken yerde durabilmek** de başarı ölçütüdür. Uydurma kolon adıyla sorgu yazan bir agent, yanlış cevaptan daha tehlikelidir çünkü güven verir.

Sonuç tablosu şöyle görünür: kaç soru doğru, hatalar hangi türde (yanlış tablo, yanlış metrik tanımı, sözlüğü okumama, uydurma kolon). Bu tablo, projeyi demodan portfolyo işine çeviren şey.

## Kapanış

Google'ın vaka çalışmaları için "bir hafta makul bir hedef" diyor. Bu daha büyük — veri toplamayı ve agent katmanını da sen yapıyorsun. Akşamları birkaç saat çalışılacak bir tempo varsayımıyla:

| Hafta | İş |
| --- | --- |
| 1 | **Sor** — iş görevi, "aktif katılımcı" tanımı, aktüeryayla mutabakat |
| 2 | **Hazırla** — raporların toplanması, hangi raporda şirket kırılımı var tespiti, kapsamın netleşmesi |
| 3 | **İşle** — başlık düzleştirme, uzun format, doğrulama |
| 4 | **İşle + Analiz Et** — PostgreSQL ambarı, kohort analizi |
| 5 | **Analiz Et + Paylaş** — bulguların netleşmesi, Tableau dashboard |
| 6 | **Ek katman** — metrik sözlüğü, simüle veri, agent |
| 7 | **Ölçüm ve kapanış** — 30 soruluk test, hata analizi, portfolyo ve README |

**Teslimat kontrol listesi:**

- [ ] İş görevinin net bir tanımı
- [ ] Veri kaynaklarının açıklaması (ROCCC değerlendirmesi dahil)
- [ ] Temizleme ve dönüştürme dokümantasyonu
- [ ] Analizin özeti
- [ ] Destekleyici görseller ve temel bulgular
- [ ] Üç öneri
- [ ] Tableau Public linki
- [ ] Metrik sözlüğü
- [ ] 30 soruluk doğruluk tablosu
- [ ] GitHub README güncel

**Bir hatırlatma:** Bu vaka çalışmasının değeri bulguların çarpıcılığından çok, muhakemesinin izlenebilirliğinde. Hangi metriği neden o şekilde tanımladığın, verinin neyi söyleyemediği, agent'ın nerede yanıldığı — bunları dürüstçe yazmak, cilalı ama boş bir sunumdan daha fazla işe yarar.

---

## Kaynaklar

- [Emeklilik Gözetim Merkezi](https://www.egm.org.tr/) — BES ve OKS istatistikleri. Tüm veriler EGM A.Ş.'ye aittir, kaynak gösterilmeden alıntı yapılamaz.
- [Devlet katkısı oranının %30'dan %20'ye indirilmesi](https://medyascope.tv/2026/01/07/beste-devlet-katkisi-yuzde-30dan-yuzde-20ye-indi/) — 7 Ocak 2026 Resmî Gazete kararı
- [Devlet katkısı hak ediş tablosu](https://www.agesa.com.tr/bes/sss)
- [BES ödemelerine ara verme kuralları](https://www.turkiyegazetesi.com.tr/tasarruf-ortagim/bes-odemelerine-ara-verilebilir-mi-beste-5-yil-siniri-1822478)
- Google Veri Analitiği Sertifikası — Cyclistic ve Bellabeat vaka çalışmaları (yapı referansı)

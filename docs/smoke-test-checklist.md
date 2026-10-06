# Uni'z Mobile — MVP Smoke Test Kontrol Listesi (Checklist)

> **Amaç:** Bu doküman, Uni'z Mobile uygulamasının MVP sürümü tamamlandığında temel kullanıcı akışlarının uçtan uca çalıştığını doğrulamak amacıyla hazırlanmıştır.  
> **Hedef Kitle:** Test uzmanları, ürün yöneticileri, stajyerler veya teknik olmayan herhangi bir incelemeci tarafından kolayca uygulanabilir.

---

## 📋 Test Oturumu Bilgileri

| Alan | Bilgi |
|:---|:---|
| **Test Eden Kişi:** | |
| **Test Tarihi:** | |
| **Test Edilen Platform / Cihaz:** | [ ] Android Emülatör &nbsp;&nbsp; [ ] Android Cihaz &nbsp;&nbsp; [ ] iOS Simülatör &nbsp;&nbsp; [ ] iOS Cihaz |
| **İşletim Sistemi Sürümü:** | |
| **Test Edilen Dal / Commit:** | |
| **Genel Test Sonucu:** | [ ] BAŞARILI &nbsp;&nbsp; [ ] BAŞARISIZ &nbsp;&nbsp; [ ] BLOKE |

---

## 🎯 Test Değerlendirme Kriterleri

- **[✓] Başarılı (Pass):** Beklenen sonuç ekranda eksiksiz ve hatasız görüntülendi.
- **[✗] Başarısız (Fail):** Ekranda çökme (crash), hatalı mesaj, UI bozulması veya akışın tıkanması yaşandı.
- **[!] Bloke (Blocked):** Bir önceki adım tamamlanamadığı için test gerçekleştirilemedi.

---

## 🧪 Smoke Test Senaryoları

---

### TC-01: Yeni Kullanıcı Kaydı (Register Flow)
*Kullanıcının e-posta ve şifre ile yeni bir hesap açabilmesi doğrulanır.*

- **Ön Koşul:** Uygulama açılmış ve giriş ekranında (`/login`) olunmalıdır.
- **Test Adımları:**
  1. Giriş ekranının altındaki **"Hesabın yok mu? Kayıt Ol"** bağlantısına tıklayın.
  2. Ad Soyad alanına geçerli bir isim girin (örn: `Ahmet Yılmaz`).
  3. E-posta alanına daha önce kullanılmamış geçerli bir e-posta girin (örn: `test_ogrenci@uniz.edu.tr`).
  4. Şifre alanına en az 6 karakterli bir şifre yazın (örn: `123456`).
  5. Şifre Tekrar alanına aynı şifreyi tekrar yazın.
  6. **"Kayıt Ol"** butonuna tıklayın.
- **Beklenen Sonuç:**
  - Butonda kısa süreli yükleniyor göstergesi belirmelidir.
  - Hesap başarıyla oluşturulmalı ve kullanıcı doğrudan **"Profilini Tamamla"** ekranına yönlendirilmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-02: Profil Bilgilerini Tamamlama (Profile Completion Flow)
*Yeni kayıt olan kullanıcının üniversite ve bölüm bilgilerini seçerek ana akışa geçebilmesi doğrulanır.*

- **Ön Koşul:** Kullanıcı yeni kayıt olmuş ve **Profil Tamamlama** (`/profile-completion`) ekranında bulunuyor olmalıdır.
- **Test Adımları:**
  1. **Üniversite Seçin** açılır kutusuna (dropdown) tıklayın ve listeden bir üniversite seçin (örn: `İstanbul Teknik Üniversitesi`).
  2. **Bölüm** alanına bölüm adınızı yazın veya listeden seçin (örn: `Bilgisayar Mühendisliği`).
  3. **Sınıf** alanından sınıf seviyenizi seçin (örn: `3. Sınıf`).
  4. **Tahmini Mezuniyet Yılı** alanından yılı seçin (örn: `2026`).
  5. Sayfanın altındaki **"Profili Tamamla"** butonuna tıklayın.
- **Beklenen Sonuç:**
  - Profil başarıyla kaydedilmeli, kullanıcı alt navigasyon çubuğu bulunan **Ana Akış (Feed)** ekranına yönlendirilmelidir.
  - Ekranın üst kısmındaki AppBar başlığı sabit olarak **"Uni'z Akış"** şeklinde görüntülenmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-03: Kullanıcı Girişi (Login Flow)
*Mevcut bir hesabın e-posta ve şifre ile giriş yapabilmesi ve hatalı şifrede doğru uyarıyı alması doğrulanır.*

- **Ön Koşul:** Kullanıcı oturumu kapalı olmalı ve giriş ekranında (`/login`) bulunmalıdır.
- **Pozitif Test Adımları:**
  1. Kayıtlı e-posta adresini ve doğru şifreyi girin.
  2. **"Giriş Yap"** butonuna tıklayın.
- **Beklenen Sonuç (Pozitif):**
  - Kullanıcı sorunsuz giriş yapmalı ve doğrudan Ana Akış (`/home`) ekranına aktarılmalıdır.
- **Negatif Test Adımları:**
  1. Şifre alanına bilerek hatalı bir şifre yazın (örn: `yanlisSifre1`).
  2. **"Giriş Yap"** butonuna tıklayın.
- **Beklenen Sonuç (Negatif):**
  - Ekranda teknik İngilizce hata (`wrong-password`, `invalid-credential` vb.) **görünmemelidir**.
  - Kullanıcıya Türkçe olarak `"Girdiğiniz şifre hatalı."` veya `"E-posta veya şifre hatalı."` uyarı mesajı (SnackBar) gösterilmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-04: Gönderi Paylaşma (Post Creation Flow)
*Kullanıcının ana akışta metin içerikli ve fotoğraflı gönderi paylaşabilmesi doğrulanır.*

- **Ön Koşul:** Kullanıcı giriş yapmış ve ana sayfada olmalıdır.
- **Test Adımları:**
  1. Alt navigasyon menüsündeki orta **"Paylaş"** sekmesine (+) tıklayın.
  2. Metin alanına kampüsle ilgili bir mesaj yazın (örn: `Yarın kütüphanede sınav çalışması yapacak var mı?`).
  3. İsteğe bağlı olarak **"Fotoğraf Ekle"** butonuna basıp galeriden bir görsel seçin.
  4. Sağ üstteki veya alttaki **"Paylaş"** butonuna tıklayın.
- **Beklenen Sonuç:**
  - Paylaşım tamamlandığında form kapanmalı ve kullanıcı **Akış** sekmesine yönlendirilmelidir.
  - Paylaşılan gönderi, yazar adı, üniversite bilgisi ve girilen metin ile birlikte akışın en üstünde görünmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-05: Gönderi Beğenme ve Geri Alma (Post Like / Unlike Flow)
*Akıştaki bir gönderinin beğenilebilmesi, sayacın anlık artması ve tekrar tıklandığında geri alınabilmesi doğrulanır.*

- **Ön Koşul:** Akışta en az bir adet gönderi bulunmalıdır.
- **Test Adımları:**
  1. Gönderi kartının altındaki boş **Kalp (Beğeni)** ikonuna tıklayın.
  2. Beğeni sayısı ve ikon durumunu gözlemleyin.
  3. Aynı dolu kırmızı kalp ikonuna tekrar tıklayın.
- **Beklenen Sonuç:**
  - İlk tıklamada kalp ikonu anında kırmızı renkle dolmalı ve yanındaki beğeni sayısı `1` artmalıdır (optimistic update).
  - İkinci tıklamada kalp ikonu tekrar boş hale dönmeli ve beğeni sayısı `1` azalmalıdır.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-06: Gönderi Raporlama (Post Report Flow)
*Uygunsuz veya kural dışı bir gönderinin raporlanabilmesi doğrulanır.*

- **Ön Koşul:** Akışta başka bir kullanıcıya ait bir gönderi görüntülenmelidir.
- **Test Adımları:**
  1. Gönderi kartının sağ üst köşesindeki **üç nokta (⋮)** butonuna tıklayın.
  2. Açılan menüden **"Raporla"** seçeneğine dokunun.
  3. Açılan alt sayfada (BottomSheet) listelenen rapor gerekçelerinden birini radyo butonu ile seçin (`Uygunsuz içerik`, `Yanlış bilgi`, `Spam`, `Telif hakkı ihlali`, `Hakaret / saldırgan içerik`, `Diğer`).
  4. Pencerenin altındaki **"Raporla"** butonuna basın.
- **Beklenen Sonuç (Pozitif):**
  - Rapor penceresi kapanmalı ve ekranda `"Raporunuz alındı. İncelenecek."` SnackBar bildirimi çıkmalıdır.
- **Negatif Kontrol (Mükerrer Raporlama):**
  - Aynı gönderi üzerinde adımlar tekrarlandığında, ekranda `"Bu içerik zaten raporlandı. Aynı içerik tekrar raporlanamaz."` uyarısı görüntülenmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-07: Ders Önerme Talebi (Suggest Course Flow)
*Kullanıcının listede bulunmayan bir ders için sisteme ekleme talebi gönderebilmesi doğrulanır.*

- **Ön Koşul:** Alt menüden **"Dersler"** sekmesine geçilmiş olmalıdır.
- **Test Adımları:**
  1. Dersler ekranındaki **"Ders Öner"** butonuna (veya liste boşsa ortadaki CTA butonuna) tıklayın.
  2. **Bölüm** alanına bölüm adınızı girin (örn: `Bilgisayar Mühendisliği`).  
     *(Kritik Kontrol: Bölüm alanı zorunludur; boş bırakılarak gönderilmeye çalışıldığında "Bölüm boş bırakılamaz." uyarısı vermelidir).*
  3. **Ders Kodu** alanına ders kodunu girin (örn: `BLG312`).
  4. **Ders Adı** alanına tam ders adını yazın (örn: `İşletim Sistemleri`).
  5. İsteğe bağlı Açıklama alanına kısa bilgi yazıp **"Ders Öner"** butonuna tıklayın.
- **Beklenen Sonuç:**
  - Form başarıyla gönderilmeli ve ekranda `"Ders öneriniz admin onayından sonra yayınlanacaktır."` bilgilendirme mesajı görüntülenmelidir.
  - Ders henüz admin onayından geçmediği için doğrudan herkesin gördüğü onaylı dersler listesine düşmemelidir (`status: pending`).
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-08: Ders Materyali Yükleme Formu ve Telif Uyarısı (Upload Material Flow)
*Ders notu veya çıkmış soru yükleme formunun çalıştığı ve telif onayı olmadan yükleme yapılamadığı doğrulanır.*

> ⚠️ **QA Notu:** `CourseDetailScreen` üzerindeki "Materyal Yükle" butonu mevcut dalda henüz stub durumunda olabilir (`"Materyal yükleme formu yakında eklenecektir."` uyarısı verebilir). Formu uçtan uca test etmek için materyal yükleme özelliğinin entegre edildiği dalı veya `/upload-material` route'unu kullanınız.

- **Ön Koşul:** Materyal yükleme ekranı (`UploadMaterialScreen`) açılmış olmalıdır.
- **Test Adımları:**
  1. **Materyal Başlığı** girin (örn: `Vize Öncesi Özet Notlar`).
  2. **Materyal Türü** açılır listesinden tür seçin (`Ders notu`, `Çıkmış soru`, `Özet`, `Diğer`).
  3. Dosya seçici ile bir PDF veya görsel dosyası seçin.
  4. **Telif Hakkı Onay Kutusunu işaretlemeden** sayfa altındaki "Yükle" butonuna basmayı deneyin.
  5. Ekrana gelen uyarıyı gözlemleyin.
  6. **Telif Hakkı Onay Kutusunu işaretleyin** ve tekrar **"Yükle"** butonuna basın.
- **Beklenen Sonuç:**
  - Telif onayı verilmeden basıldığında işlem engellenmeli ve ekranda `"Lütfen telif hakkı uyarısını onaylayın."` SnackBar'ı görünmelidir.
  - Telif onayı verilip yüklendiğinde işlem başarıyla tamamlanmalı ve ekranda `"Ders materyali başarıyla yüklendi. Admin onayından sonra yayınlanacaktır."` mesajı görüntülenmelidir (`status: pending`).
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-09: Kampüs Etkinliklerini Listeleme (Events List Flow)
*Etkinlikler sekmesinde onaylanmış etkinliklerin doğru kart tasarımıyla listelendiği doğrulanır.*

- **Ön Koşul:** Alt menüden **"Etkinlikler"** sekmesine tıklanmalıdır.
- **Test Adımları:**
  1. Etkinlikler ekranını açın.
  2. Listelenen etkinlik kartlarını inceleyin.
  3. Eğer sistemde henüz onaylı etkinlik yoksa ekranın boş durumunu (Empty State) kontrol edin.
- **Beklenen Sonuç:**
  - Etkinlik varsa; Etkinlik Adı, Düzenleyen Topluluk, Tarih/Saat, Konum bilgileri net ve okunaklı görünmelidir.
  - Etkinlik yoksa; turuncu etkinlik temalı **"Henüz etkinlik yok"** boş ekran görseli ve **"Etkinlik Ekle"** butonu görüntülenmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-10: Bildirim İzni İsteme (Notification Permission Flow)
*Uygulamanın kullanıcıdan push bildirim göndermek için sistem izni talep ettiği doğrulanır.*

> ⚠️ **QA Notu:** Bu test **Android 13+ (API 33+)** veya bildirim destekleyen fiziksel / simülatör **iOS** cihazında yürütülmelidir (Android 12 ve daha eski sürümlerde işletim sistemi bildirim iznini kurulumda otomatik verir, ayrı diyalog tetiklenmez). Ayrıca bu özellik Milestone 10 (#65) FCM entegrasyonu tamamlandığında doğrulanabilir.

- **Ön Koşul:** Uygulama cihaza sıfırdan kurulmuş veya bildirim izinleri ayarlarından sıfırlanmış olmalıdır.
- **Test Adımları:**
  1. Uygulamayı başlatıp giriş yapın.
  2. Sistem tarafından gösterilen bildirim izin penceresini bekleyin.
- **Beklenen Sonuç:**
  - Ekranda `"Uni'z bildirim göndermek istiyor"` şeklinde işletim sistemi bildirim izin diyaloğu açılmalıdır.
  - İzin verildiğinde işlem çökmeksizin devam etmeli, kullanıcı profilinde bildirim altyapısı hazır hale gelmelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-11: Banlı Kullanıcı Aksiyon Kısıtlaması (Banned User Guard Flow)
*Yönetici tarafından banlanmış (`isBanned: true`) bir kullanıcının tespit edildiği ve yetkisiz aksiyon almasının engellendiği doğrulanır.*

- **Ön Koşul:** Veritabanında `isBanned: true` olarak işaretlenmiş bir test hesabı bulunmalıdır.
- **Senaryo A (Girişte Yönlendirme):**
  1. Banlı hesap bilgileri ile login olun.
  - **Beklenen Sonuç:** Kullanıcı ana akış yerine doğrudan özel kısıtlama ekranına (`/banned` - `BannedUserScreen`) yönlendirilir. Ekranda **"Hesabınız Kısıtlandı"** başlığı, kısıtlama açıklaması ve "Çıkış Yap" butonu görüntülenir.
- **Senaryo B (Aksiyon Sırasında Koruma):**
  1. Kullanıcı oturum halindeyken banlandıysa veya bir korumalı butona basarsa (post paylaşma, beğenme, ders/materyal önerme, raporlama):
  - **Beklenen Sonuç:** İşlem durdurulur ve ekranda şu standart kısıtlama uyarısı belirir:  
    `"Hesabınız geçici olarak kısıtlanmıştır. Bu işlemi şu anda gerçekleştiremezsiniz."`
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

### TC-12: Kullanıcı Çıkışı (Logout Flow)
*Oturumun güvenli bir şekilde kapatılarak kullanıcı verilerinin temizlendiği ve login ekranına dönüldüğü doğrulanır.*

- **Ön Koşul:** Kullanıcı oturumu açık olmalı ve **Profil** sekmesinde bulunmalıdır.
- **Test Adımları:**
  1. Alt menüden en sağdaki **"Profil"** sekmesine dokunun.
  2. Sayfanın en altındaki gri çerçeveli **"Çıkış Yap"** (`OutlinedButton`) butonuna tıklayın.  
     *(Alternatif: Feed ekranının üst AppBar'ında yer alan Çıkış Yap ikon butonuna da dokunulabilir).*  
     *(Kritik Not: Uygulamada ayrı bir onay modalı bulunmamaktadır; butona tıklandığı anda oturum doğrudan kapatılır).*
- **Beklenen Sonuç:**
  - Oturum anında sonlandırılmalı, kullanıcı tüm oturum geçmişi temizlenmiş olarak doğrudan **Giriş Yap (`/login`)** ekranına aktarılmalıdır.
  - Cihazın "Geri" tuşuna basıldığında profil ekranına veya ana sayfaya geri dönülmemelidir.
- **Sonuç:** `[ ] Başarılı` &nbsp;&nbsp; `[ ] Başarısız` &nbsp;&nbsp; `[ ] Bloke`  
  *Notlar:* 

---

## 📊 Test Sonuç Özeti

| Toplam Test Sayısı | Başarılı (Pass) | Başarısız (Fail) | Bloke (Blocked) | Başarı Oranı |
|:---:|:---:|:---:|:---:|:---:|
| **12** | | | | % |

### İncelemeci İmza ve Kararı:
- **Test Eden:** ___________________
- **İmza / Tarih:** ___________________
- **Nihai Karar:** [ ] MVP Canlıya Alınabilir &nbsp;&nbsp; [ ] Düzeltme Gerekiyor (Hotfix)

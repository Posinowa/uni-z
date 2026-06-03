# Uni’z Project Context & Development Guide

> Bu dosya, Uni’z projesinin ana bağlam dosyasıdır ve repo kök dizininde yer alır.  
> Stajyerler, geliştiriciler ve AI kod asistanları bu dosyayı okuyarak projenin amacını, kapsamını, teknik kararlarını ve geliştirme sınırlarını anlamalıdır.  
> Bu dosyada belirtilmeyen büyük kararlar geliştirici veya AI tarafından kendiliğinden alınmamalıdır.

---

## 1. Proje Özeti

**Proje adı:** Uni’z  
**Platform:** Mobil uygulama + admin panel  
**İlk geliştirme odağı:** Flutter mobil uygulama  
**Admin panel:** Daha sonra ayrı private repository olarak geliştirilecektir.  
**Hedef kullanıcı:** Üniversite öğrencileri  
**İlk MVP süresi:** 2 hafta  
**Ana amaç:** Üniversite öğrencilerinin kendi üniversite yaşamlarıyla ilgili sosyal içeriklere, ders notlarına, çıkmış sorulara, etkinliklere ve kampüs gündemine tek yerden ulaşabileceği bir öğrenci ekosistemi oluşturmak.

Uni’z, sadece bir ders notu paylaşım uygulaması değildir. Uygulama; sosyal akış, kampüs etkinlikleri, ders kaynakları, çıkmış sorular, öğrenci profilleri, raporlama ve bildirim altyapısı içeren bir kampüs ekosistemi olarak tasarlanacaktır.

---

## 2. Ürün Vizyonu

Uni’z, üniversite öğrencileri için kampüs yaşamını dijital hale getiren bir platformdur.

Bir öğrenci Uni’z’e girdiğinde şu sorulara cevap bulabilmelidir:

- Bugün kampüste ne oluyor?
- Hangi etkinlikler var?
- Bölümümde hangi dersler var?
- Bu ders için hangi notlar ve çıkmış sorular yüklenmiş?
- Diğer öğrenciler ne paylaşıyor?
- Üniversitemde hangi duyurular ve gündemler var?
- Faydalı içerikleri kimler paylaşıyor?

Uygulamanın temel vaadi:

> Uni’z, üniversite hayatına ait sosyal paylaşımları, ders kaynaklarını ve kampüs etkinliklerini tek yerde toplayan öğrenci ekosistemidir.

---

## 3. Marka Kimliği

### 3.1 Uygulama İsmi

Uygulama adı **Uni’z** olacaktır.

Yazım standardı:

```text
Uni’z
```

Alternatif yazımlar kullanılmamalıdır:

```text
Uniz       // kullanılmamalı
UniZ       // kullanılmamalı
Uni'z      // tercih edilmez
Uni’s      // kullanılmamalı
Unigo      // kullanılmamalı
```

### 3.2 Marka Hissi

Uni’z şu hissi vermelidir:

- Genç
- Modern
- Güvenilir
- Sosyal
- Kampüs odaklı
- Faydalı
- Dinamik
- Sade ama enerjik

Uygulama çok kurumsal görünmemelidir. Aynı zamanda fazla çocukça, oyuncak gibi veya karmaşık da görünmemelidir.

### 3.3 Slogan Önerisi

Ana slogan:

```text
Üniversite hayatın tek yerde.
```

Alternatif kısa slogan:

```text
Kampüste ne varsa burada.
```

---

## 4. Renk Paleti

Uni’z için ana renk paleti aşağıdaki gibi kullanılacaktır.

### 4.1 Ana Renkler

```text
Primary Indigo: #4F46E5
Secondary Cyan: #06B6D4
Accent Purple: #A855F7
Background: #F8FAFC
Card/Surface: #FFFFFF
Text Primary: #0F172A
Text Secondary: #64748B
Border: #E2E8F0
Success: #22C55E
Warning: #F59E0B
Error: #EF4444
```

### 4.2 Gradient Kullanımı

Splash, onboarding, ana CTA veya marka alanlarında şu gradient kullanılabilir:

```text
#4F46E5 → #06B6D4
```

Gradient abartılı kullanılmamalıdır. Ana ekranlarda sade beyaz/kırık beyaz arka plan tercih edilmelidir.

### 4.3 Kategori Renkleri

```text
Dersler / Notlar: #4F46E5
Etkinlikler: #F97316
Topluluklar: #A855F7
Kampüs Duyuruları: #06B6D4
Rapor / Uyarı: #EF4444
Onaylandı: #22C55E
Beklemede: #F59E0B
```

---

## 5. Teknik Kararlar

### 5.1 Mobil Uygulama

Mobil uygulama Flutter ile geliştirilecektir.

```text
Framework: Flutter
State Management: Provider
Auth: Firebase Auth
Database: Firestore
Notification: Firebase Cloud Messaging
Storage: Cloudflare R2
Backend: MVP aşamasında özel backend yoktur
```

### 5.2 Backend Kararı

MVP aşamasında özel backend geliştirilmeyecektir. Sistem backendsiz gibi kurgulanacak, backend görevini Firebase servisleri üstlenecektir.

Kullanılacak Firebase servisleri:

```text
Firebase Auth
Firestore
Firebase Cloud Messaging
Firebase Security Rules
Firebase Cloud Functions opsiyonel
```

Cloudflare R2 kullanılacak alanlar:

```text
Profil fotoğrafları
Post görselleri
Ders notları
Çıkmış sorular
Etkinlik görselleri
```

Firestore’da dosyanın kendisi değil, dosya metadata bilgileri tutulacaktır.

Örnek:

```text
fileUrl
fileKey
fileType
fileSize
uploadedBy
createdAt
status
```

### 5.3 Admin Panel

Admin panel ayrı bir private repository olarak geliştirilecektir.

```text
Framework: Next.js
Auth: Firebase Auth
Database: Firestore
Notification Management: Firebase Cloud Messaging
Storage Metadata: Firestore + Cloudflare R2
Repository: private
```

Admin panel geliştirmesine, mobil uygulamada bildirim altyapısı tamamlanmaya başladığında geçilecektir.

---

## 6. Repository Kararı

Mobil uygulama public repository olarak açılacaktır.

Admin panel ayrı private repository olacaktır.

### 6.1 Mobil Repo Önerilen Adı

```text
uniz-mobile
```

### 6.2 Admin Repo Önerilen Adı

```text
uniz-admin
```

---

## 7. Branch Stratejisi

Projede şu branch yapısı kullanılacaktır:

```text
main
production branch
sadece proje sahibi merge edebilir

develop
aktif geliştirme branch’i
stajyerler doğrudan push atamaz
sadece PR ile değişiklik gelir
sadece proje sahibi merge edebilir

feature/*
yeni özellik branch’leri

fix/*
hata düzeltme branch’leri

chore/*
setup, config, dokümantasyon işleri
```

Örnek branch isimleri:

```text
feature/login-screen
feature/register-screen
feature/feed-post-card
feature/course-list-screen
feature/material-upload-form
feature/fcm-token-save
fix/auth-validation-error
chore/github-actions-setup
```

---

## 8. Pull Request Kuralları

Her PR develop branch’ine açılmalıdır.

PR’lar küçük ve tek amaçlı olmalıdır. Bir PR birden fazla büyük özelliği içermemelidir.

Her PR şu kurallara uymalıdır:

- PR hedefi `develop` olmalıdır.
- PR açıklamasında ilgili issue numarası bulunmalıdır.
- PR tek bir issue’yu çözmelidir.
- Gereksiz refactor yapılmamalıdır.
- Issue kapsamı dışındaki dosyalara dokunulmamalıdır.
- `.env`, secret, private key veya servis hesabı dosyaları commitlenmemelidir.
- Lint hatası bırakılmamalıdır.
- Build bozulmamalıdır.
- Kullanılmayan dosya, class, widget veya component eklenmemelidir.
- AI tarafından eklenen gereksiz yorumlar, mock datalar ve alakasız kodlar silinmelidir.

### 8.1 PR Template

Her PR açıklaması şu formatta olmalıdır:

```md
Closes #ISSUE_NUMBER

## Yapılanlar
- 

## Ekran Görüntüsü
- 

## Test
- 

## Notlar
- 
```

---

## 9. AI Kullanım Kuralları

Bu proje stajyerler tarafından AI destekli geliştirilebilir. Ancak AI asistanları bu dosyada belirtilen kapsam dışına çıkmamalıdır.

### 9.1 AI İçin Ana Talimat

AI kod asistanına her issue için şu bilgi verilmelidir:

```text
Bu proje Uni’z projesidir. PROJECT_CONTEXT.md dosyasındaki kurallara kesinlikle uy.
Sadece issue’da belirtilen kapsamda değişiklik yap.
Allowed Files dışında dosya değiştirme.
Yeni mimari karar alma.
Yeni paket ekleme gerekiyorsa önce gerekçesini açıkla.
Backend yazma, çünkü MVP Firebase tabanlıdır.
State management olarak Provider dışına çıkma.
UI renklerinde proje renk paletini kullan.
```

### 9.2 AI’nın Yapmaması Gerekenler

AI şunları yapmamalıdır:

- Gereksiz büyük refactor
- Proje mimarisini değiştirme
- Provider yerine Bloc, Riverpod, GetX gibi farklı yapı ekleme
- Firebase yerine başka auth/database sistemi ekleme
- Cloudflare R2 yerine Firebase Storage kullanmaya karar verme
- Backend klasörü veya API server ekleme
- Issue kapsamı dışı ekran oluşturma
- Alakasız dependency ekleme
- Mock data ile kalıcı çözüm üretme
- Secret veya env değerlerini koda gömme
- Kullanılmayan dosya, widget, model veya servis oluşturma
- Admin panel kodunu mobil repo içine yazma
- Yorum sistemini MVP’ye ekleme
- DM, takip veya topluluk sayfalarını MVP’ye ekleme

### 9.3 AI’nın Uyması Gerekenler

AI şunlara uymalıdır:

- Küçük ve okunabilir kod yazmalı
- Dosya yapısına uymalı
- Mevcut naming convention’a uymalı
- Sadece issue kapsamındaki işi yapmalı
- UI’da proje renk paletini kullanmalı
- Provider ile state yönetmeli
- Firestore veri modeline uymalı
- Banlı kullanıcı kontrolünü dikkate almalı
- Admin onayı gereken içeriklerde `status: pending` mantığını kullanmalı
- Raporlama gereken içeriklerde reports collection mantığını kullanmalı

---

## 10. MVP Kapsamı

MVP kapsamı 2 haftalık geliştirme süresine göre dar tutulmuştur.

### 10.1 MVP’de Olacaklar

```text
Email/password ile kayıt ve giriş
Profil tamamlama
Üniversite seçimi
Bölüm seçimi
Ana akış
Metin postu oluşturma
Fotoğraflı post oluşturma
Post beğenme
Post raporlama
Ders listeleme
Ders ekleme talebi
Ders materyali yükleme talebi
Çıkmış soru yükleme talebi
Etkinlik listeleme
Etkinlik detay ekranı
Etkinlik oluşturma talebi, sadece yetkili/topluluk rolü için
FCM token kaydetme
Bildirim alma altyapısı
Banlı kullanıcı kontrolü
Telif uyarı metni
Admin onay statüleri için temel veri modeli
```

### 10.2 MVP’de Olmayacaklar

```text
Yorum sistemi
Takip sistemi
DM / mesajlaşma
Anonim paylaşım
Topluluk sayfaları
Edu mail doğrulama
AI not özeti
Ders programı oluşturma
Gelişmiş arama
Canlı sohbet
Ödeme sistemi
Premium üyelik
Detaylı gamification
```

Bu özellikler daha sonraki sürümlerde değerlendirilebilir.

---

## 11. Kullanıcı Rolleri

MVP’de temel roller:

```text
student
admin
community
```

### 11.1 student

Normal üniversite öğrencisidir.

Yapabilir:

- Kayıt olabilir
- Profil oluşturabilir
- Post paylaşabilir
- Post beğenebilir
- İçerik raporlayabilir
- Ders ekleme talebi gönderebilir
- Ders materyali yükleme talebi gönderebilir
- Onaylanmış dersleri ve materyalleri görebilir
- Onaylanmış etkinlikleri görebilir

Yapamaz:

- Admin onayı olmadan ders/material/event yayınlayamaz
- Etkinlik oluşturamaz, eğer community rolü yoksa
- Kullanıcı banlayamaz
- Bildirim gönderemez

### 11.2 community

Doğrulanmış topluluk veya etkinlik oluşturma yetkisi olan hesaptır.

Yapabilir:

- Etkinlik oluşturma talebi gönderebilir
- Kendi oluşturduğu etkinlikleri görebilir

MVP’de topluluk sayfası yoktur. Sadece rol bazlı etkinlik oluşturma yetkisi vardır.

### 11.3 admin

Admin panel üzerinden sistemi yönetir.

Yapabilir:

- Kullanıcıları görebilir
- Kullanıcı banlayabilir
- İçerikleri silebilir/gizleyebilir
- Dersleri onaylayabilir/reddedebilir
- Materyalleri onaylayabilir/reddedebilir
- Etkinlikleri onaylayabilir/reddedebilir
- Raporları inceleyebilir
- Bildirim gönderebilir

---

## 12. Auth ve Kayıt Akışı

İlk MVP’de email/password kullanılacaktır.

### 12.1 Register Akışı

Kullanıcı şu bilgilerle kayıt olur:

```text
Ad soyad
E-posta
Şifre
Üniversite
Bölüm
Sınıf
Tahmini mezuniyet yılı
Telefon, opsiyonel
Profil fotoğrafı, opsiyonel
```

Kayıt sonrası Firebase Auth hesabı oluşturulur. Ardından Firestore `users/{userId}` belgesi oluşturulur.

### 12.2 Login Akışı

Kullanıcı email/password ile giriş yapar.

Giriş sonrası:

- Kullanıcının Firestore profil kaydı kontrol edilir.
- Eğer profil eksikse profile completion ekranına yönlendirilir.
- Eğer kullanıcı banlıysa uygulama içinde yetkileri kısıtlanır.

### 12.3 Edu Mail Doğrulama

MVP’de yoktur.

İleride eklenecektir:

```text
.edu.tr veya üniversite domain doğrulaması
verified student badge
okul bazlı doğrulanmış kullanıcı filtreleri
```

---

## 13. Ana Navigasyon

Mobil uygulamada önerilen bottom navigation:

```text
Akış
Dersler
Paylaş
Etkinlikler
Profil
```

### 13.1 Akış

Sosyal paylaşımların listelendiği alandır.

### 13.2 Dersler

Üniversite/bölüm/ders bazlı kaynakların listelendiği alandır.

### 13.3 Paylaş

Post oluşturma için merkezi butondur.

### 13.4 Etkinlikler

Kampüs etkinliklerinin listelendiği alandır.

### 13.5 Profil

Kullanıcı profil bilgilerinin ve kendi içeriklerinin bulunduğu alandır.

---

## 14. İçerik Yayınlama Mantığı

### 14.1 Sosyal Postlar

Normal sosyal postlar doğrudan yayınlanabilir.

Ancak:

- Raporlanabilir olmalıdır.
- Admin panelinden gizlenebilir/silinebilir olmalıdır.
- Banlı kullanıcı post paylaşamamalıdır.

Post status değerleri:

```text
published
hidden
removed
```

### 14.2 Dersler

Kullanıcı ders ekleme talebi gönderebilir.

Dersler admin onayından geçmeden herkese açık yayınlanmamalıdır.

Ders status değerleri:

```text
pending
approved
rejected
```

### 14.3 Ders Materyalleri

Kullanıcı ders notu, çıkmış soru veya kaynak dosya yükleyebilir.

Materyaller admin onayından geçmeden yayınlanmamalıdır.

Materyal status değerleri:

```text
pending
approved
rejected
```

### 14.4 Etkinlikler

Etkinlik oluşturma sadece `community` veya gerekli yetkiye sahip kullanıcılar için geçerlidir.

Etkinlikler admin onayından geçmeden yayınlanmamalıdır.

Event status değerleri:

```text
pending
approved
rejected
```

---

## 15. Firestore Veri Modeli

Aşağıdaki veri modeli MVP için referans kabul edilmelidir. Büyük değişiklik yapılmamalıdır.

### 15.1 users

```js
users/{userId} {
  id: string,
  fullName: string,
  email: string,
  phone: string | null,
  universityId: string,
  universityName: string,
  departmentId: string,
  departmentName: string,
  classYear: number,
  expectedGraduationYear: number,
  profileImageUrl: string | null,
  role: "student" | "admin" | "community",
  isVerifiedStudent: boolean,
  isBanned: boolean,
  fcmTokens: string[],
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 15.2 universities

```js
universities/{universityId} {
  id: string,
  name: string,
  city: string,
  isActive: boolean,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

Üniversite listesi hazır listeden çekilecektir.

### 15.3 departments

```js
departments/{departmentId} {
  id: string,
  universityId: string,
  name: string,
  status: "pending" | "approved" | "rejected",
  createdBy: string,
  createdAt: timestamp,
  approvedBy: string | null,
  approvedAt: timestamp | null
}
```

Kullanıcılar bölüm ekleyebilir, ancak onay gerekir.

### 15.4 posts

```js
posts/{postId} {
  id: string,
  authorId: string,
  authorName: string,
  authorPhotoUrl: string | null,
  universityId: string,
  universityName: string,
  departmentId: string | null,
  departmentName: string | null,
  type: "general" | "campus" | "announcement",
  text: string,
  imageUrls: string[],
  likeCount: number,
  reportCount: number,
  status: "published" | "hidden" | "removed",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 15.5 postLikes

```js
postLikes/{postId_userId} {
  id: string,
  postId: string,
  userId: string,
  createdAt: timestamp
}
```

Aynı kullanıcı aynı postu birden fazla beğenmemelidir.

### 15.6 courses

```js
courses/{courseId} {
  id: string,
  universityId: string,
  universityName: string,
  departmentId: string,
  departmentName: string,
  courseCode: string,
  courseName: string,
  description: string | null,
  status: "pending" | "approved" | "rejected",
  createdBy: string,
  createdAt: timestamp,
  approvedBy: string | null,
  approvedAt: timestamp | null
}
```

### 15.7 courseMaterials

```js
courseMaterials/{materialId} {
  id: string,
  courseId: string,
  universityId: string,
  departmentId: string,
  uploadedBy: string,
  title: string,
  description: string | null,
  type: "lecture_note" | "past_exam" | "summary" | "other",
  fileUrl: string,
  fileKey: string,
  fileType: string,
  fileSize: number,
  status: "pending" | "approved" | "rejected",
  reportCount: number,
  createdAt: timestamp,
  approvedBy: string | null,
  approvedAt: timestamp | null
}
```

### 15.8 events

```js
events/{eventId} {
  id: string,
  title: string,
  description: string,
  universityId: string,
  universityName: string,
  location: string,
  eventDate: timestamp,
  imageUrl: string | null,
  imageKey: string | null,
  createdBy: string,
  organizerName: string,
  status: "pending" | "approved" | "rejected",
  createdAt: timestamp,
  approvedBy: string | null,
  approvedAt: timestamp | null
}
```

### 15.9 reports

```js
reports/{reportId} {
  id: string,
  targetType: "post" | "material" | "event" | "user",
  targetId: string,
  reportedBy: string,
  reason: string,
  description: string | null,
  status: "open" | "reviewed" | "resolved" | "rejected",
  createdAt: timestamp,
  reviewedBy: string | null,
  reviewedAt: timestamp | null
}
```

### 15.10 notifications

```js
notifications/{notificationId} {
  id: string,
  title: string,
  body: string,
  targetType: "all" | "university" | "department" | "user",
  targetId: string | null,
  sentBy: string,
  createdAt: timestamp,
  sentAt: timestamp | null,
  status: "draft" | "sent" | "failed"
}
```

MVP’de admin panelden tüm kullanıcılara bildirim gönderme yeterlidir. Filtreli bildirim daha sonra eklenebilir.

---

## 16. Cloudflare R2 Kullanımı

Dosya ve görseller Cloudflare R2’ye yüklenecektir.

### 16.1 R2’de Tutulacak Dosyalar

```text
Profil fotoğrafları
Post görselleri
Ders materyali PDF/görselleri
Çıkmış soru dosyaları
Etkinlik görselleri
```

### 16.2 Önerilen R2 Key Yapısı

```text
users/{userId}/profile/{fileName}
posts/{postId}/{fileName}
courses/{courseId}/materials/{materialId}/{fileName}
events/{eventId}/{fileName}
```

### 16.3 Firestore Metadata

Firestore’da sadece şu bilgiler tutulmalıdır:

```text
fileUrl
fileKey
fileType
fileSize
uploadedBy
createdAt
```

R2 erişim anahtarları koda gömülmemelidir.

MVP’de doğrudan client-side upload için güvenli imzalı URL yapısı gerekiyorsa, Firebase Cloud Functions veya güvenli bir ara çözüm değerlendirilmelidir. Ancak AI kendi başına yeni backend mimarisi oluşturmamalıdır.

---

## 17. Bildirim Sistemi

Firebase Cloud Messaging kullanılacaktır.

### 17.1 Mobil Taraf

Mobil uygulama:

- Bildirim izni istemelidir.
- FCM token almalıdır.
- Token’ı `users/{userId}.fcmTokens` alanına kaydetmelidir.
- Foreground notification handle etmelidir.
- Background notification handle etmelidir.

### 17.2 Admin Taraf

Admin panelde bildirim gönderme ekranı olacaktır.

MVP’de öncelik:

```text
Admin tüm kullanıcılara bildirim gönderebilir.
```

Daha sonra:

```text
Üniversiteye göre bildirim
Bölüme göre bildirim
Tek kullanıcıya bildirim
```

---

## 18. Raporlama Sistemi

Kullanıcılar içerikleri raporlayabilir.

Raporlanabilecek hedefler:

```text
post
material
event
user
```

Rapor nedenleri:

```text
Uygunsuz içerik
Yanlış bilgi
Spam
Telif hakkı ihlali
Hakaret / saldırgan içerik
Diğer
```

Rapor oluşturulduğunda `reports` collection’a kayıt atılmalıdır. İlgili hedef içeriğin `reportCount` alanı artırılabilir.

---

## 19. Ban Sistemi

Admin kullanıcıyı banlayabilir.

Banlı kullanıcı uygulamaya giriş yapabilir ancak aşağıdaki işlemleri yapamaz:

```text
Post paylaşma
Post beğenme
Ders ekleme
Materyal yükleme
Etkinlik oluşturma
Raporlama
```

Banlı kullanıcıya uygun ve sade bir uyarı gösterilmelidir.

Örnek:

```text
Hesabınız geçici olarak kısıtlanmıştır. Bu nedenle içerik paylaşamazsınız.
```

---

## 20. Telif ve İçerik Uyarısı

Ders materyali veya çıkmış soru yüklemeden önce kullanıcıya uyarı gösterilmelidir.

Önerilen metin:

```text
Lütfen yalnızca paylaşma hakkınız olan ders notlarını, özetleri veya kaynakları yükleyin. Telif hakkı ihlali, kişisel veri içeren belgeler veya izinsiz paylaşımlar kaldırılabilir. İçeriğin sorumluluğu yükleyen kullanıcıya aittir.
```

Kullanıcı bu uyarıyı onaylamadan dosya yükleyememelidir.

---

## 21. UI/UX İlkeleri

### 21.1 Genel Arayüz İlkeleri

- Mobil öncelikli tasarım yapılmalıdır.
- Ekranlar sade olmalıdır.
- Kart tabanlı içerik yapısı tercih edilmelidir.
- Gereksiz animasyonlardan kaçınılmalıdır.
- Genç ve modern his korunmalıdır.
- Her ekranın ana amacı net olmalıdır.
- Empty state tasarımları unutulmamalıdır.
- Loading state ve error state eklenmelidir.

### 21.2 Önerilen Ana Ekran Yapısı

```text
Top area:
Selam, {firstName}
Üniversite adı

Content:
Post cards
Etkinlik cards
Ders önerileri

Bottom navigation:
Akış | Dersler | Paylaş | Etkinlikler | Profil
```

### 21.3 Component Yaklaşımı

Tekrar kullanılabilir widget/component yazılmalıdır.

Örnek:

```text
AppButton
AppTextField
AppCard
PostCard
CourseCard
EventCard
LoadingView
EmptyStateView
ErrorView
```

---

## 22. Flutter Dosya Yapısı

Önerilen dosya yapısı:

```text
lib/
 ├── app/
 │   ├── app.dart
 │   ├── routes.dart
 │   └── theme.dart
 │
 ├── core/
 │   ├── constants/
 │   ├── errors/
 │   ├── utils/
 │   └── services/
 │
 ├── features/
 │   ├── auth/
 │   │   ├── models/
 │   │   ├── providers/
 │   │   ├── screens/
 │   │   ├── services/
 │   │   └── widgets/
 │   │
 │   ├── profile/
 │   ├── feed/
 │   ├── courses/
 │   ├── events/
 │   ├── notifications/
 │   └── reports/
 │
 ├── shared/
 │   ├── widgets/
 │   ├── models/
 │   └── services/
 │
 └── main.dart
```

AI veya stajyerler bu yapıyı değiştirmemelidir.

---

## 23. Provider Kullanımı

State management için Provider kullanılacaktır.

Kullanılmaması gerekenler:

```text
Bloc
Riverpod
GetX
MobX
Redux
```

Provider örnek kullanım alanları:

```text
AuthProvider
UserProvider
FeedProvider
CourseProvider
EventProvider
NotificationProvider
```

---

## 24. Geliştirme Sırası

Önce mobil uygulama geliştirilecektir. Admin panel daha sonra başlayacaktır.

### 24.1 Mobil Öncelik Sırası

```text
1. Proje setup
2. Firebase setup
3. Auth ekranları
4. Provider auth state
5. Profil tamamlama
6. Ana layout ve bottom navigation
7. Feed ekranı
8. Post oluşturma
9. Beğeni
10. Raporlama
11. Ders listesi
12. Ders ekleme talebi
13. Materyal yükleme talebi
14. Etkinlik listesi
15. Etkinlik oluşturma talebi
16. FCM token kaydetme
17. Bildirim alma altyapısı
```

### 24.2 Admin Panel Öncelik Sırası

```text
1. Next.js setup
2. Firebase setup
3. Admin login
4. Dashboard
5. Kullanıcı listesi
6. Kullanıcı banlama
7. Pending courses
8. Pending materials
9. Pending events
10. Reports
11. Send notification
```

---

## 25. Issue Formatı

Her issue küçük ve net olmalıdır.

Issue formatı:

```md
## Amaç
Bu issue’da yapılacak işin kısa açıklaması.

## Kapsam
- 

## Kapsam Dışı
- 

## Allowed Files
- 

## Kabul Kriterleri
- 

## Teknik Notlar
- 
```

### 25.1 Allowed Files Zorunluluğu

Her issue’da Allowed Files alanı olmalıdır.

Örnek:

```md
## Allowed Files
- lib/features/auth/**
- lib/shared/widgets/**
```

AI ve stajyerler bu dosyalar dışında değişiklik yapmamalıdır.

---

## 26. İlk MVP Issue Başlıkları

### Setup

```text
Initialize Flutter project for Uni’z Mobile
Configure Firebase project
Add base folder architecture
Add app theme and color palette
Add GitHub PR template
Add GitHub issue template
Add CODEOWNERS file
Add Flutter CI workflow
Add PR target branch guard
Add issue reference checker
Add changed files limit checker
Add forbidden secrets file checker
```

### Auth

```text
Create login screen UI
Create register screen UI
Connect Firebase Auth email/password login
Connect Firebase Auth email/password registration
Add auth state management with Provider
Add logout functionality
Add forgot password screen
```

### Profile

```text
Create user profile data model
Create profile completion screen
Add university selection field
Add department selection field
Save user profile to Firestore
Create profile detail screen
Add edit profile screen
```

### Feed

```text
Create feed post data model
Create post card component
Create feed list screen
Create text post form
Add image picker for post creation
Upload post image to Cloudflare R2
Save post metadata to Firestore
Add like/unlike feature
Add report post feature
```

### Courses

```text
Create university data model
Create department data model
Create course data model
Create course list screen
Create course detail screen
Create course creation form
Save pending course requests to Firestore
Create course material data model
Create material upload form
Upload material file to Cloudflare R2
Save pending material request to Firestore
Add report material feature
Add copyright warning before upload
```

### Events

```text
Create event data model
Create event list screen
Create event detail screen
Create event creation form for community users
Save pending event request to Firestore
Add report event feature
```

### Notifications

```text
Configure Firebase Cloud Messaging in Flutter
Request notification permission on iOS and Android
Save user FCM token to Firestore
Handle foreground notifications
Handle background notifications
Create notification service class
```

### Moderation

```text
Add banned user access control
Add content report data model
Add approval status handling for courses
Add approval status handling for materials
Add approval status handling for events
```

---

## 27. CI/CD Kuralları

GitHub Actions ile aşağıdaki kontroller yapılmalıdır:

```text
Flutter analyze
Flutter test
Flutter build apk
PR target branch check
Issue reference check
Changed file limit check
Forbidden file check
Secret scan
```

### 27.1 Değişen Dosya Limiti

Bir PR’da en fazla 15 dosya değişmelidir.

15 dosyadan fazla değişiklik varsa PR fail olabilir veya uyarı verebilir. MVP döneminde fail etmesi önerilir.

### 27.2 Yasaklı Dosyalar

Aşağıdaki dosyalar commitlenmemelidir:

```text
.env
.env.local
.env.production
firebase-service-account.json
serviceAccountKey.json
*.pem
*.key
*.p12
```

---

## 28. Güvenlik İlkeleri

- Secret değerler repoya eklenmemelidir.
- Firebase config public olabilir ancak service account private kalmalıdır.
- R2 access key ve secret key client koduna gömülmemelidir.
- Firestore Security Rules mutlaka yazılmalıdır.
- Banlı kullanıcı kontrolleri sadece UI’da değil, mümkünse rule seviyesinde de düşünülmelidir.
- Kullanıcılar sadece kendi profilini düzenleyebilmelidir.
- Admin işlemleri sadece admin rolüne sahip kullanıcılar tarafından yapılabilmelidir.

---

## 29. Firestore Security Rules İçin Genel Mantık

Bu dosya rules kodunu kesin olarak tanımlamaz, ancak genel mantık şudur:

```text
users:
- Kullanıcı kendi profilini okuyabilir/güncelleyebilir.
- Admin tüm kullanıcıları okuyabilir/güncelleyebilir.

posts:
- Published postları giriş yapan kullanıcılar okuyabilir.
- Banlı olmayan kullanıcı post oluşturabilir.
- Kullanıcı kendi postunu oluşturabilir.
- Admin post status değiştirebilir.

courses/materials/events:
- Approved içerikler okunabilir.
- Pending içerikler oluşturan kullanıcı ve admin tarafından görülebilir.
- Onay/reddetme sadece admin tarafından yapılabilir.

reports:
- Banlı olmayan kullanıcı rapor oluşturabilir.
- Admin raporları okuyabilir ve güncelleyebilir.
```

---

## 30. Kod Kalitesi Kuralları

- Dosya isimleri anlaşılır olmalıdır.
- Büyük widgetlar parçalanmalıdır.
- UI, service ve model katmanları karıştırılmamalıdır.
- Firestore işlemleri doğrudan ekran içinde yazılmamalı, service/provider katmanında olmalıdır.
- Aynı kod tekrar tekrar yazılmamalıdır.
- Magic string ve magic number azaltılmalıdır.
- Error handling yapılmalıdır.
- Loading state gösterilmelidir.
- Empty state gösterilmelidir.
- Kullanıcıya teknik hata mesajı gösterilmemelidir.

---

## 31. Tasarım ve Kullanıcı Deneyimi Notları

### 31.1 Login/Register

- Sade ve güven veren ekranlar olmalıdır.
- Uni’z gradient kullanılabilir.
- Çok fazla form alanı tek ekranda boğucu olmamalıdır.
- Kayıt sonrası profil tamamlama ayrı adım olabilir.

### 31.2 Feed

- Post kartları temiz ve okunabilir olmalıdır.
- Kullanıcı adı, üniversite ve bölüm bilgisi görünmelidir.
- Beğeni ve raporlama butonları sade olmalıdır.
- Yorum alanı eklenmemelidir.

### 31.3 Dersler

- Üniversite ve bölüm bağlamı net olmalıdır.
- Ders kartlarında ders kodu ve adı görünmelidir.
- Materyaller türlerine göre ayrılmalıdır: Ders Notu, Çıkmış Soru, Özet, Diğer.

### 31.4 Etkinlikler

- Etkinlik kartında tarih, saat, konum ve başlık net görünmelidir.
- Görsel varsa kartı zenginleştirmelidir.
- Etkinlik oluşturma sadece yetkili kullanıcıya gösterilmelidir.

---

## 32. Admin Panel Kapsamı

Admin panel mobil repodan ayrı private repo olacaktır.

Admin panelde MVP için olacaklar:

```text
Admin login
Dashboard
Kullanıcı listesi
Kullanıcı detay
Kullanıcı ban/unban
Pending courses
Pending materials
Pending events
Reported content
Send notification to all users
```

Admin panelde MVP’de olmayacaklar:

```text
Gelişmiş analytics
Rol yönetimi detayları
Topluluk sayfası yönetimi
Ücretli üyelik yönetimi
Gelişmiş bildirim segmentasyonu
```

---

## 33. 2 Haftalık MVP Planı

### Hafta 1

```text
Gün 1:
Repo setup
Flutter setup
Firebase setup
GitHub Actions başlangıç
Tema ve klasör yapısı

Gün 2:
Login ekranı
Register ekranı
Firebase Auth bağlantısı
Provider auth state

Gün 3:
Profil tamamlama ekranı
Üniversite seçimi
Bölüm seçimi
Firestore users kaydı

Gün 4:
Ana layout
Bottom navigation
Feed ekranı
PostCard component

Gün 5:
Post oluşturma
Fotoğraf seçme
Post Firestore kaydı
Beğeni sistemi
```

### Hafta 2

```text
Gün 6:
Ders listeleme
Ders detay ekranı
Ders ekleme talebi

Gün 7:
Ders materyali yükleme
Telif uyarısı
R2 upload hazırlığı
courseMaterials kaydı

Gün 8:
Etkinlik listeleme
Etkinlik detay
Etkinlik oluşturma talebi

Gün 9:
Raporlama sistemi
Banlı kullanıcı kontrolü
Approval status handling

Gün 10:
Firebase Cloud Messaging setup
FCM token kaydı
Bildirim alma altyapısı
Admin panel repo hazırlığı
```

---

## 34. Gelecek Sürüm Fikirleri

MVP sonrasında düşünülebilecek özellikler:

```text
Edu mail doğrulama
Topluluk sayfaları
Yorum sistemi
Gelişmiş arama
Ders programı oluşturma
AI destekli ders notu özeti
AI ile çıkmış soru analizi
Kampüs skoru / katkı puanı
Rozet sistemi
Üniversite bazlı liderlik tablosu
Etkinliğe katılacağım özelliği
Takvim entegrasyonu
Bildirim segmentasyonu
Gelişmiş admin analytics
```

Bu özellikler MVP’ye dahil edilmemelidir.

---

## 35. Proje Sahibi Kararları

Aşağıdaki kararlar kesindir:

```text
Uygulama adı Uni’z olacaktır.
Mobil uygulama Flutter ile yapılacaktır.
Admin panel ayrı private repo olacaktır.
Admin panel Next.js ile yapılacaktır.
MVP’de özel backend yazılmayacaktır.
Firebase backend gibi kullanılacaktır.
Dosya/görsel yükleme için Cloudflare R2 kullanılacaktır.
State management Provider olacaktır.
Normal email/password giriş kullanılacaktır.
Edu mail doğrulama sonraki sürüme bırakılacaktır.
Tüm üniversitelere açık olacaktır.
Üniversite hazır listeden seçilecektir.
Kullanıcılar bölüm/ders/materyal ekleyebilecektir.
Yapısal içerikler admin onayından geçecektir.
Sosyal postlarda anonimlik olmayacaktır.
Yorum sistemi MVP’de olmayacaktır.
Beğeni sistemi olacaktır.
Takip sistemi olmayacaktır.
DM olmayacaktır.
Raporlama olacaktır.
Ban sistemi olacaktır.
Admin bildirim gönderebilecektir.
Stajyerler önce mobil uygulamada çalışacaktır.
Her issue küçük görevlerden oluşacaktır.
PR’larda issue dışı değişiklik engellenecektir.
```

---

## 36. AI İçin Son Hatırlatma

Bu proje üzerinde çalışan AI kod asistanı şu kurala uymalıdır:

> Verilen issue’nun dışına çıkma. Bu dosyada belirtilen mimari ve ürün kararlarını değiştirme. Gerekli olmadıkça yeni paket ekleme. Admin paneli mobil repoya yazma. Backend oluşturma. Provider dışına çıkma. Firebase + Firestore + FCM + Cloudflare R2 kararlarına uy. Kodları küçük, okunabilir ve MVP kapsamına uygun tut.

---

## 37. Kısa Proje Tanımı

Uni’z, üniversite öğrencilerinin kampüs yaşamını, ders kaynaklarını, çıkmış soruları, etkinlikleri ve sosyal paylaşımları tek yerde takip edebildiği Flutter tabanlı bir mobil uygulamadır. MVP aşamasında Firebase Auth, Firestore, Firebase Cloud Messaging ve Cloudflare R2 kullanılarak backendsiz bir yapı kurulacaktır. Admin panel daha sonra ayrı bir Next.js private repository olarak geliştirilecektir.

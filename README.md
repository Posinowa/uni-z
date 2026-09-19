# Uni'z Mobile

> **Üniversite hayatın tek yerde.**  
> Üniversite öğrencilerinin kampüs yaşamını, ders kaynaklarını, çıkmış soruları, etkinlikleri ve sosyal paylaşımları tek bir çatı altında takip edebildiği Flutter tabanlı mobil kampüs ekosistemi.

---

## 📌 İçindekiler

1. [Proje Hakkında](#-proje-hakkında)
2. [Teknoloji Yığını (Tech Stack)](#-teknoloji-yığını-tech-stack)
3. [Gereksinimler (Prerequisites)](#-gereksinimler-prerequisites)
4. [Adım Adım Lokal Kurulum](#-adım-adım-lokal-kurulum)
5. [Firebase Yapılandırması](#-firebase-yapılandırması)
6. [Ortam Değişkenleri (.env)](#-ortam-değişkenleri-env)
7. [Proje Mimarisi ve Klasör Yapısı](#-proje-mimarisi-ve-klasör-yapısı)
8. [Git İş Akışı ve PR Kuralları](#-git-iş-akışı-ve-pr-kuralları)
9. [Güvenlik ve Yasaklı Dosyalar](#-güvenlik-ve-yasaklı-dosyalar)
10. [Sık Karşılaşılan Sorunlar (Troubleshooting)](#-sık-karşılaşılan-sorunlar-troubleshooting)
11. [Faydalı Terminal Komutları](#-faydalı-terminal-komutları)
12. [Stajyer Onboarding ve Dokümantasyon](#-stajyer-onboarding-ve-dokümantasyon)

---

## 🎓 Proje Hakkında

Uni'z, yalnızca bir ders notu paylaşım uygulaması değildir. Öğrencilerin kampüs gündemini yakalamasını, ders materyallerini paylaşmasını, etkinliklerden haberdar olmasını ve kampüs içi sosyal etkileşimi artıran dinamik bir platformdur.

MVP aşamasında doğrudan Firebase servisleri (Auth, Firestore, FCM) ve dosya depolama için Cloudflare R2 kullanılarak sunucusuz (backendless) bir mimari ile geliştirilmektedir. Yönetici işlemleri için Next.js tabanlı Admin Panel ayrı bir repoda yer alır.

---

## 🛠 Teknoloji Yığını (Tech Stack)

| Alan | Teknoloji / Kütüphane | Notlar |
|:---|:---|:---|
| **Framework** | Flutter 3.10+ | Mobil öncelikli (Android & iOS) |
| **Dil** | Dart 3.10+ | Null safety aktif |
| **State Management**| Provider (^6.1.2) | Projede Bloc, Riverpod veya GetX kullanılmaz |
| **Kimlik Doğrulama** | Firebase Auth | Email & şifre ile kayıt ve giriş |
| **Veritabanı** | Cloud Firestore | NoSQL doküman tabanlı veri modeli |
| **Bildirimler** | Firebase Cloud Messaging (FCM) | Push ve in-app bildirim altyapısı |
| **Dosya Depolama** | Cloudflare R2 | Profil, gönderi, not ve etkinlik görselleri/PDF |
| **Hata Yönetimi** | `AppErrorMapper` (Merkezi) | Kullanıcı dostu Türkçe hata mesajları |
| **Tasarım / Stil** | Vanilla Flutter / Uni'z Design System | Özel renk paleti ve kart tabanlı UI |

---

## 💻 Gereksinimler (Prerequisites)

Geliştirmeye başlamadan önce sisteminizde aşağıdaki araçların kurulu olduğundan emin olun:

- **Flutter SDK:** ^3.10.4 veya üzeri ([Flutter Kurulum Kılavuzu](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** ^3.10.4 veya üzeri (Flutter ile birlikte gelir)
- **Git:** Sürüm kontrolü için
- **IDE:** Android Studio veya VS Code (Flutter & Dart eklentileri yüklü olmalıdır)
- **Platform Araçları:**
  - **Android:** Android Studio, Android SDK Platform-Tools ve en az bir Android Emülatörü
  - **iOS (Yalnızca macOS):** Xcode 14+, Command Line Tools ve CocoaPods (`sudo gem install cocoapods`)

Sisteminizin hazır olduğunu doğrulamak için terminalde şu komutu çalıştırın:

```bash
flutter doctor
```

---

## 🚀 Adım Adım Lokal Kurulum

Projeyi yerel makinenizde sıfırdan çalıştırmak için sırasıyla şu adımları izleyin:

### 1. Repoyu Klonlayın
```bash
git clone https://github.com/Posinowa/uni-z.git
cd uni-z
```

### 2. Geliştirme Dalına Geçin
Tüm aktif geliştirme `develop` dalı üzerinden yürütülür:
```bash
git checkout develop
git pull origin develop
```

### 3. Ortam Değişkenlerini Tanımlayın
Örnek yapılandırma dosyasından yerel `.env` dosyanızı oluşturun:
```bash
cp .env.example .env
```
> [!IMPORTANT]
> `.env` dosyası yerel ortamda kalmalıdır ve repoya **kesinlikle commit edilmemelidir**.

### 4. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 5. Kod Analizi ve Testleri Çalıştırın
Projeyi başlatmadan önce statik analizin ve testlerin sorunsuz geçtiğinden emin olun:
```bash
flutter analyze lib test
flutter test
```

### 6. Uygulamayı Başlatın
Bir emülatör veya bağlı fiziksel cihaz seçerek uygulamayı çalıştırın:
```bash
flutter run
```
Web ortamında hızlı UI kontrolü yapmak isterseniz:
```bash
flutter run -d chrome
```

---

## 🔥 Firebase Yapılandırması

Uni'z Mobile; kimlik doğrulama, veritabanı ve bildirimler için Firebase altyapısını kullanır.

### Stajyerler İçin Yapılandırma Adımları:
1. Proje yöneticisinden (`@yusufyilmazf`) Firebase konsol projesine davet talep edin.
2. Firebase Console üzerinden projenin yapılandırma dosyalarını indirin:
   - **Android için:** `google-services.json` dosyasını `android/app/` klasörüne yerleştirin.
   - **iOS için:** `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne yerleştirin.
3. Bu dosyalar `.gitignore` dosyasında tanımlıdır. Git durumunuzu kontrol ederek dosyaların stage edilmediğinden emin olun:
   ```bash
   git status
   ```

> [!CAUTION]
> `google-services.json` ve `GoogleService-Info.plist` dosyaları hassas kimlik bilgileri içerir. Bu dosyaları **asla commit etmeyin veya public alanlarda paylaşmayın**.

Detaylı bilgi için: [docs/firebase-setup-guide.md](docs/firebase-setup-guide.md)

---

## 📂 Proje Mimarisi ve Klasör Yapısı

Uni'z Mobile projesinde **Feature-First (Özellik Odaklı)** klasör mimarisi uygulanmaktadır:

```
lib/
 ├── app/              # Uygulama çekirdeği (app.dart, routes.dart, theme.dart)
 ├── core/             # Uygulama genelinde kullanılan temel modüller
 │   ├── constants/    # Renk paleti, spacing, radius, collection sabitleri
 │   ├── errors/       # AppErrorMapper ve merkezi hata yönetimi
 │   ├── helpers/      # Yardımcı sınıflar ve export yönlendirmeleri
 │   └── services/     # Temel servis sınıfları (FirestoreBaseService vb.)
 ├── features/         # İş mantığı ve ekran bazlı modüller
 │   ├── auth/         # Giriş, kayıt, şifre sıfırlama (models, providers, screens, services)
 │   ├── profile/      # Profil tamamlama, detay ve düzenleme ekranları
 │   ├── feed/         # Ana akış, gönderi kartı, post oluşturma, beğeni
 │   ├── courses/      # Ders listesi, detay, materyal yükleme ve ders önerisi
 │   ├── events/       # Etkinlik listesi, detay ve etkinlik oluşturma talebi
 │   ├── notifications/# FCM servisleri ve bildirim dinleyicileri
 │   └── reports/      # İçerik ve kullanıcı raporlama akışı
 ├── shared/           # Ortak kullanılan bileşenler
 │   ├── models/       # Paylaşılan veri modelleri
 │   ├── utils/        # Doğrulayıcılar (Validators) ve formatlayıcılar
 │   └── widgets/      # AppButton, AppTextField, AppEmptyState vb. ortak widget'lar
 └── main.dart         # Uygulama başlangıcı ve Provider root kayıtları
```

---

## 🌿 Git İş Akışı ve PR Kuralları

Projeye katkı sağlarken aşağıdaki kurallara harfiyen uyulmalıdır:

### 1. Branch Açma
Her geliştirme için doğrudan `develop` dalı üzerinden yeni bir branch oluşturulmalıdır:
```bash
git checkout develop
git pull origin develop
git checkout -b maa/feature/issue-<NO>-<kisa-aciklama>
```
*Örnek:* `maa/feature/issue-72-readme-setup`

### 2. Pull Request (PR) Standartları
- **Hedef Dal:** Bütün PR'lar istisnasız **`develop`** dalına açılmalıdır.
- **Issue Bağlantısı:** PR açıklamasının ilk satırında ilgili GitHub issue numarası belirtilmelidir:  
  `Closes #NUMARA`
- **Allowed Files Kısıtı:** Her issue'da belirtilen `Allowed Files` dizinleri dışındaki dosyalara dokunulmamalıdır.
- **Değişen Dosya Limiti:** Bir PR içerisinde **en fazla 15 dosya** değişikliği bulunabilir.
- **CI Doğrulaması:** GitHub Actions üzerindeki tüm test ve analiz kontrolleri yeşil olmalıdır.

Detaylı rehber: [docs/contribution-guide.md](docs/contribution-guide.md) & [docs/git-workflow.md](docs/git-workflow.md)

---

## 🔒 Güvenlik ve Yasaklı Dosyalar

Aşağıdaki dosyalar veya uzantılar **kesinlikle repoya commit edilmemelidir**:

```text
.env
.env.local
.env.production
google-services.json
GoogleService-Info.plist
firebase-service-account.json
serviceAccountKey.json
*.pem, *.key, *.p12
```

Cloudflare R2 veya Firebase servis hesap anahtarları asla istemci (client) koduna doğrudan gömülmemelidir.

---

## ❓ Sık Karşılaşılan Sorunlar (Troubleshooting)

### 1. `.env` Dosyası Bulunamadı Hatası
**Hata:** Uygulama başlarken `Unable to load asset: .env` hatası ile kapanıyor.  
**Çözüm:** Kök dizinde `.env` dosyasının bulunduğundan emin olun:
```bash
cp .env.example .env
flutter clean && flutter pub get
```

### 2. iOS CocoaPods / Pod Install Sorunları
**Hata:** `pod install` sırasında hata alınıyor veya build fail veriyor.  
**Çözüm:** Pod önbelleğini temizleyip yeniden yükleyin:
```bash
cd ios
pod deintegrate
pod repo update
pod install
cd ..
```

### 3. Firebase Yapılandırması Eksik
**Hata:** `FirebaseApp not initialized` veya platform kanal hataları alınıyor.  
**Çözüm:** Android için `android/app/google-services.json`, iOS için `ios/Runner/GoogleService-Info.plist` dosyalarının doğru dizinlerde olduğunu kontrol edin.

### 4. `flutter analyze` Çok Fazla Hata Buluyor
**Hata:** `flutter analyze` komutu `build/` veya platform dosyalarını analiz ederek yüzlerce uyarı veriyor.  
**Çözüm:** Yalnızca kaynak ve test kodlarını analiz etmek için komutu hedef belirterek çalıştırın:
```bash
flutter analyze lib test
```

---

## ⚡ Faydalı Terminal Komutları

```bash
# Bağımlılıkları yükleme
flutter pub get

# Statik kod analizi
flutter analyze lib test

# Tüm birim ve widget testlerini çalıştırma
flutter test

# Belirli bir test dosyasını çalıştırma
flutter test test/core/errors/app_error_mapper_test.dart

# Build önbelleğini temizleme
flutter clean

# Uygulamayı hata ayıklama modunda çalıştırma
flutter run

# Web ortamında çalıştırma
flutter run -d chrome
```

---

## 📖 Stajyer Onboarding ve Dokümantasyon

Geliştirme sürecine başlamadan önce aşağıdaki dokümanları sırasıyla okumanız önerilir:

1. [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) — Proje vizyonu, mimari kurallar ve MVP kapsamı
2. [docs/intern-onboarding.md](docs/intern-onboarding.md) — Stajyerler için ilk gün başlangıç rehberi
3. [docs/git-workflow.md](docs/git-workflow.md) — Git branch stratejisi ve günlük akış
4. [docs/contribution-guide.md](docs/contribution-guide.md) — Katkı sağlama ve PR kuralları
5. [docs/firebase-setup-guide.md](docs/firebase-setup-guide.md) — Firebase servisleri kurulum rehberi
6. [docs/github-issue-index.md](docs/github-issue-index.md) — Issue numaraları ve eşleştirme dizini
7. [docs/mvp-roadmap.md](docs/mvp-roadmap.md) — MVP geliştirme yol haritası

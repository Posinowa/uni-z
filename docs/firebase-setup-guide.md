# Firebase Setup Guide

Uni'z Mobile Firebase altyapısı kurulum ve stajyer dağıtım rehberi.

> Issue #7 (Firebase dependencies) ve #8 (Firebase initialization) öncesinde bu adımlar tamamlanmalıdır.

## Firebase Projesi

| Alan | Değer |
|------|-------|
| Platform | Firebase (Auth, Firestore, Cloud Messaging) |
| Backend | MVP'de özel backend yok |
| Dosya depolama | Cloudflare R2 (Firebase Storage değil) |

## Proje Sahibi Yapacakları

### 1. Firebase Console'da proje oluştur

1. [Firebase Console](https://console.firebase.google.com/) → Yeni proje
2. Proje adı: `uniz-mobile` (veya benzeri)
3. Google Analytics: opsiyonel (MVP'de gerekli değil)

### 2. Android uygulaması ekle

1. Firebase Console → Project Settings → Add app → Android
2. Package name: `com.posinowa.uniz.uniz_mobile`
3. `google-services.json` indir
4. **Repoya commit etme**

### 3. iOS uygulaması ekle

1. Add app → iOS
2. Bundle ID: Firebase'de tanımlanan bundle ID
3. `GoogleService-Info.plist` indir
4. **Repoya commit etme**

### 4. Firebase servislerini etkinleştir

- **Authentication** → Email/Password provider'ı aç
- **Firestore Database** → Test mode veya production rules ile oluştur
- **Cloud Messaging** → Otomatik etkin

### 5. Firestore Security Rules (ilk sürüm)

MVP başlangıcında temel kurallar yazılmalı. Detay: [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) — Bölüm 29.

## Stajyer Dağıtım Planı

Secret dosyalar repoya **asla** commit edilmez. Stajyerlere şu yöntemlerden biriyle dağıt:

### Yöntem A — Güvenli kanal (önerilen)

1. Proje sahibi stajyeri Firebase projesine **Viewer** veya **Editor** olarak davet eder
2. Stajyer kendi `google-services.json` ve `GoogleService-Info.plist` dosyalarını indirir
3. Dosyaları lokal olarak doğru konumlara koyar:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

### Yöntem B — Şifreli paylaşım

1. Proje sahibi dosyaları şifreli kanaldan paylaşır (1Password, güvenli drive)
2. Stajyer lokal kurulum yapar
3. `.gitignore` bu dosyaları zaten engellemez ama **commit etmemeli**

### Yöntem C — FlutterFire CLI

Issue #8 kapsamında `flutterfire configure` kullanılacaksa:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Bu komut `lib/firebase_options.dart` üretir. Bu dosya **repoya commit edilebilir** (public config, secret değil).

## Environment Variables

`.env.example` dosyasını `.env` olarak kopyala:

```bash
cp .env.example .env
```

Cloudflare R2 alanları Issue #52+ öncesinde doldurulması gerekmez.

## Doğrulama

Stajyer kurulumu tamamlandığında:

```bash
flutter pub get
flutter run
```

Uygulama Firebase initialize hatası vermeden açılmalı (Issue #8 sonrası).

## Güvenlik Kuralları

- `firebase-service-account.json` repoya **asla** eklenmez
- `.env` dosyası commit edilmez
- R2 access key client koduna gömülmez
- Admin SDK sadece admin panel (ayrı repo) tarafında kullanılır

## Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| `google-services.json` bulunamadı | Dosyayı `android/app/` altına koy |
| iOS build hatası | `GoogleService-Info.plist` → `ios/Runner/` |
| Firebase initialize fail | `flutterfire configure` tekrar çalıştır |
| Permission denied Firestore | Security rules kontrol et |

## İlgili Issue'lar

- GitHub #7 — Add Firebase dependencies
- GitHub #8 — Configure Firebase initialization
- GitHub #9 — Add environment example file
- GitHub #10 — Add Firestore service base class

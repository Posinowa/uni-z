# Uni'z Mobile

Üniversite öğrencileri için kampüs ekosistemi — Flutter mobil uygulama.

## Tech Stack

| Alan | Teknoloji |
|------|-----------|
| Framework | Flutter 3.10+ |
| State Management | Provider |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| Notifications | Firebase Cloud Messaging |
| File Storage | Cloudflare R2 |
| Backend | Yok (MVP Firebase tabanlı) |

## Requirements

- Flutter SDK 3.10+
- Dart 3.10+
- Android Studio / Xcode (platform geliştirme için)
- Git

## Setup

```bash
git clone https://github.com/Posinowa/uni-z.git
cd uni-z
git checkout develop
flutter pub get
flutter analyze
flutter test
flutter run
```

## Firebase Setup

Firebase yapılandırması Issue #7–#8 kapsamında yapılır. Kurulum öncesi proje sahibinden Firebase erişimi al.

Detaylı rehber: [docs/firebase-setup-guide.md](docs/firebase-setup-guide.md)

## Environment Variables

```bash
cp .env.example .env
```

`.env` dosyasını **asla commit etme**. Sadece `.env.example` repoda bulunur.

## Branch Workflow

| Branch | Amaç |
|--------|------|
| `main` | Production (sadece proje sahibi merge) |
| `develop` | Aktif geliştirme (PR ile) |
| `feature/*` | Yeni özellik branch'leri |

Aktif geliştirme **`develop`** branch'inde yapılır. PR'lar yalnızca `develop`'a açılır.

Detay: [docs/git-workflow.md](docs/git-workflow.md)

## PR Rules

- Her PR tek issue kapatmalı (`Closes #NUMARA`)
- Hedef branch: `develop`
- Max 15 dosya değişikliği
- CI 7 workflow geçmeli
- Code owner review gerekli (`@yusufyilmazf`)
- Allowed Files dışına çıkma
- Secret/env dosyası commit etme

Detay: [docs/contribution-guide.md](docs/contribution-guide.md)

## Useful Commands

```bash
flutter pub get          # Bağımlılıkları yükle
flutter analyze          # Statik analiz
flutter test             # Testleri çalıştır
flutter run              # Uygulamayı başlat
flutter run -d chrome    # Web'de çalıştır
flutter clean            # Build cache temizle
```

## Proje Yapısı

```
lib/
 ├── app/           # App-level config
 ├── core/          # Constants, theme, routing, services
 ├── features/      # Feature modules (auth, feed, courses...)
 ├── shared/        # Shared widgets, models, utils
 └── main.dart
```

Feature-based architecture. Detay: [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)

## Stajyerler İçin

1. [docs/intern-onboarding.md](docs/intern-onboarding.md) — İlk gün rehberi
2. [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) — Proje kuralları ve mimari
3. [docs/github-issue-index.md](docs/github-issue-index.md) — Issue numaraları
4. [docs/mvp-roadmap.md](docs/mvp-roadmap.md) — Geliştirme sırası

## Güvenlik Uyarısı

Aşağıdaki dosyaları **asla** commit etme:

```
.env
.env.local
firebase-service-account.json
serviceAccountKey.json
*.pem, *.key, *.p12
```

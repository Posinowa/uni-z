# Stajyer Onboarding

Uni'z Mobile projesine hoş geldin. Bu rehber ilk gün yapman gerekenleri adım adım anlatır.

## 1. Ortam Kurulumu

### Gereksinimler

- Flutter SDK 3.10+
- Git
- Android Studio veya VS Code + Flutter extension
- GitHub hesabı (Posinowa org erişimi)

### Projeyi clone et

```bash
git clone https://github.com/Posinowa/uni-z.git
cd uni-z
git checkout develop
flutter pub get
flutter analyze
flutter test
flutter run
```

Ana ekranda **Uni'z Mobile** yazısını görmelisin.

## 2. Okuman Gereken Dosyalar (sırayla)

| Sıra | Dosya | Neden |
|------|-------|-------|
| 1 | [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) | Projenin tüm kuralları, mimarisi, MVP kapsamı |
| 2 | [Git Workflow](git-workflow.md) | Branch kuralları |
| 3 | [Contribution Guide](contribution-guide.md) | Issue ve PR süreci |
| 4 | [MVP Roadmap](mvp-roadmap.md) | Hangi sırayla çalışılacak |
| 5 | [GitHub Issue Index](github-issue-index.md) | Issue numaraları |

## 3. Issue Numaraları (Önemli)

PR açarken **GitHub issue numarasını** kullan. Plan dokümanındaki numara farklı olabilir.

| GitHub # | Konu |
|----------|------|
| #1 | App color palette (ilk geliştirme issue'su) |
| #11 | Login screen UI |
| #32 | Home shell + bottom navigation |

Tam liste: [github-issue-index.md](github-issue-index.md)

## 4. İlk Issue'nu Al

1. [GitHub Issues](https://github.com/Posinowa/uni-z/issues) → Milestone **M1 — Theme, Routing & Shared UI**
2. **#1 — Add app color palette and theme constants** ile başla
3. Issue body'deki Allowed Files ve Kabul Kriterleri'ni oku
4. Branch aç:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/issue-1-app-color-palette
```

## 5. Geliştirme ve PR

```bash
# Kod yaz...
flutter analyze
flutter test

git add .
git commit -m "Add app color palette and theme constants"
git push -u origin feature/issue-1-app-color-palette
```

GitHub'da PR aç:
- **Base:** `develop`
- **Body:** `Closes #1` + PR şablonunu doldur

## 6. AI ile Çalışma

Cursor veya başka AI aracı kullanıyorsan her issue için şu prompt'u ver:

```txt
PROJECT_CONTEXT.md dosyasını oku.

Şu GitHub issue üzerinde çalışıyorum:

[ISSUE METNİNİ BURAYA YAPIŞTIR]

Kurallar:
- Sadece issue kapsamındaki işi yap.
- Allowed Files dışındaki dosyalara dokunma.
- Gereksiz refactor yapma.
- Yeni dependency eklemen gerekiyorsa önce açıkla.
- Firebase, Flutter ve Provider mimarisine sadık kal.
- Backend yazma.
- Cloudflare R2 secret key kullanma.
- Kodları junior geliştiricinin anlayacağı sadelikte yaz.
- PR küçük ve review edilebilir olmalı.
```

## 7. Firebase (Issue #7'den itibaren)

Issue #7–#8 (Firebase dependencies + initialization) öncesinde proje sahibinden şunları iste:

- Firebase projesine davet
- `google-services.json` (Android) — repoya **commit etme**, lokal kullan
- `GoogleService-Info.plist` (iOS) — repoya **commit etme**, lokal kullan

Detay: [Firebase Setup Guide](firebase-setup-guide.md)

## 8. PR Checklist (kısa)

- [ ] Hedef branch `develop`
- [ ] `Closes #GITHUB_NUMARASI` yazıldı
- [ ] Allowed Files dışına çıkılmadı
- [ ] `flutter analyze` ve `flutter test` geçti
- [ ] Max 15 dosya değişikliği
- [ ] Secret/env dosyası yok
- [ ] `lib/` altında debug çıktısı yok
- [ ] UI değişikliğinde ekran görüntüsü eklendi

## 9. Kimden Yardım Alınır?

- Code review: `@yusufyilmazf`
- Teknik kararlar: PROJECT_CONTEXT.md + proje sahibi
- Issue kapsamı belirsizse: issue'da yorum aç, onay bekle

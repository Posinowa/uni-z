# Contribution Guide

Uni'z Mobile projesine katkı rehberi.

## Başlamadan Önce

1. [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) dosyasını oku
2. [Intern Onboarding](intern-onboarding.md) adımlarını takip et
3. [Git Workflow](git-workflow.md) kurallarını öğren

## Issue Nasıl Alınır?

1. [GitHub Issues](https://github.com/Posinowa/uni-z/issues) sayfasına git
2. Milestone ve label'a göre sıradaki issue'yu seç
3. Issue body'deki şu bölümleri oku:
   - **Amaç** — Ne yapılacak
   - **Allowed Files** — Hangi dosyalara dokunabilirsin
   - **Kapsam Dışı** — Ne yapılmayacak
   - **Kabul Kriterleri** — Ne zaman "bitti" sayılır
4. Issue'yu kendine ata (Assignees)
5. `feature/issue-<NUMARA>-<aciklama>` branch'i aç

## Kod Yazarken

- Sadece issue **Allowed Files** listesindeki dosyalara dokun
- Gereksiz refactor yapma
- `print(`, `debugPrint(`, `developer.log(` kullanma (`lib/` altında yasak)
- Hardcoded renk yerine tema sabitlerini kullan (hazır olduktan sonra)
- State management: **Provider** (Bloc, Riverpod, GetX yasak)
- Backend yazma — MVP Firebase tabanlıdır

## PR Nasıl Açılır?

### 1. Lokal test

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

### 2. Push ve PR

- Hedef branch: **`develop`**
- PR şablonu otomatik gelir — tüm alanları doldur
- **Mutlaka** şunu ekle: `Closes #ISSUE_NUMARASI`

Örnek:

```md
Closes #1

## Yapılanlar
- AppColors sınıfı oluşturuldu
- AppSpacing ve AppRadius eklendi

## Test
- [x] flutter analyze çalıştırıldı
- [x] flutter test çalıştırıldı
- [x] Uygulama lokal olarak açıldı
```

### 3. PR kuralları

| Kural | Açıklama |
|-------|----------|
| Tek issue | Her PR tek issue kapatmalı |
| Max 15 dosya | Daha fazlası CI'da fail |
| Issue referansı | `Closes #`, `Fixes #` veya `Resolves #` zorunlu |
| CI yeşil | 7 workflow geçmeli |
| Code review | `@yusufyilmazf` onayı gerekli |
| Ekran görüntüsü | UI değişikliği varsa ekle |

## CI Kontrolleri

Her PR'da şu workflow'lar çalışır:

| Workflow | Ne kontrol eder |
|----------|-----------------|
| Flutter Analyze | Statik analiz |
| Flutter Test | Unit/widget testler |
| PR Target Guard | Hedef branch `develop` mi |
| Issue Reference Checker | PR'da issue referansı var mı |
| Changed Files Limit | Max 15 dosya |
| Forbidden Files Checker | Secret dosya var mı |
| Debug Output Checker | `lib/` altında debug çıktısı var mı |

## Review Sonrası

- Review yorumlarını düzelt
- Push et (CI tekrar çalışır)
- Onay alındıktan sonra proje sahibi merge eder
- Merge sonrası feature branch'ini sil

## Sık Yapılan Hatalar

| Hata | Çözüm |
|------|-------|
| PR `main`'e açıldı | Kapat, `develop`'a yeniden aç |
| `Closes #14` yazıldı (doc numarası) | GitHub numarasını kullan: `Closes #1` |
| 16+ dosya değişti | PR'ı böl |
| `.env` commit'lendi | Commit'ten çıkar, `.gitignore`'a güven |
| Allowed Files dışına çıkıldı | Sadece izin verilen dosyaları değiştir |

## Yardım

- Teknik kararlar: [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md)
- Issue eşleştirme: [GitHub Issue Index](github-issue-index.md)
- MVP sırası: [MVP Roadmap](mvp-roadmap.md)

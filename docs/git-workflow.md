# Git Workflow

Uni'z Mobile reposunda kullanılan branch ve merge kuralları.

## Branch Yapısı

| Branch | Amaç | Kim merge eder |
|--------|------|----------------|
| `main` | Production branch | Sadece proje sahibi |
| `develop` | Aktif geliştirme branch'i | Sadece proje sahibi (PR ile) |
| `feature/*` | Yeni özellik | Stajyer PR açar |
| `fix/*` | Hata düzeltme | Stajyer PR açar |
| `chore/*` | Setup, config, dokümantasyon | Stajyer PR açar |

## Stajyer Kuralları

- PR'lar **yalnızca `develop` branch'ine** açılmalıdır.
- `main` branch'ine doğrudan PR açmak yasaktır (CI fail eder).
- `develop` ve `main` branch'lerine **doğrudan push yapılamaz**.
- Stajyerler `write` yetkisiyle **feature branch'e push** edebilir.

## Branch Adlandırma

```
feature/issue-<NUMARA>-<kisa-aciklama>
fix/issue-<NUMARA>-<kisa-aciklama>
chore/issue-<NUMARA>-<kisa-aciklama>
```

Örnekler:

```
feature/issue-1-app-color-palette
feature/issue-11-login-screen-ui
fix/issue-42-auth-validation-error
chore/issue-85-readme-setup
```

`<NUMARA>` = GitHub issue numarası (plan dokümanı numarası değil).

## Günlük Akış

```bash
# 1. develop'ı güncelle
git checkout develop
git pull origin develop

# 2. Feature branch aç
git checkout -b feature/issue-1-app-color-palette

# 3. Değişiklikleri yap, commit et
git add .
git commit -m "Add app color palette and theme constants"

# 4. Remote'a push et
git push -u origin feature/issue-1-app-color-palette

# 5. GitHub'da PR aç (hedef: develop)
```

## Merge Süreci

1. Stajyer PR açar → `develop` hedefli
2. CI workflow'ları otomatik çalışır (7 kontrol)
3. `@yusufyilmazf` code review yapar
4. Tüm CI yeşil + onay alındıktan sonra proje sahibi merge eder
5. Stajyer feature branch'ini silebilir

## Yasaklar

- `main` veya `develop`'a doğrudan push
- Force push
- Issue kapsamı dışında dosya değiştirme
- `.env`, secret veya private key commit'leme
- Tek PR'da birden fazla issue çözme
- 15'ten fazla dosya değiştiren PR

## İlgili Dosyalar

- [Contribution Guide](contribution-guide.md)
- [Intern Onboarding](intern-onboarding.md)
- [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) — Bölüm 7

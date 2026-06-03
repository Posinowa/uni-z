# MVP Roadmap

Uni'z Mobile 2 haftalık MVP geliştirme planı.

> GitHub issue numaraları kullanılır. Tam eşleştirme: [github-issue-index.md](github-issue-index.md)

## Milestone Özeti

| Milestone | GitHub Issue'lar | Konu |
|-----------|------------------|------|
| M0 — Setup & Governance | #74–#86 (kapalı) | Proje kurulumu, CI, dokümantasyon |
| M1 — Theme & Shared UI | #1–#6 | Tema, butonlar, inputlar, routing |
| M2 — Firebase Foundation | #7–#10 | Firebase paketleri, init, Firestore base |
| M3 — Auth | #11–#21 | Login, register, AuthProvider |
| M4 — Profile | #22–#31 | Profil tamamlama, Firestore users |
| M5 — Home Navigation | #32 | Bottom navigation shell |
| M6 — Feed & Posts | #33–#42 | Post oluşturma, beğeni |
| M7 — Reports | #43–#45 | Raporlama sistemi |
| M8 — Courses | #46–#57 | Dersler, materyaller |
| M9 — Events | #58–#64 | Etkinlikler |
| M10 — Notifications | #65–#67 | FCM, token kaydı |
| M11 — Moderation | #68–#69 | Ban kontrolü |
| M12 — Polish | #70–#73 | Empty state, error handling, README |

## Sprint 1 — Gün 1–3

```
#1  App color palette and theme constants
#2  Apply global app theme
#3  Shared button components
#4  Shared text input components
#5  Loading, empty and error state widgets
#6  App routing structure
#7  Firebase dependencies
#8  Configure Firebase initialization
```

## Sprint 1 — Gün 4–7

```
#11 Login screen UI
#12 Register screen UI
#13 Forgot password screen UI
#14 Auth form validation
#15 AuthService with Firebase Auth
#16 AuthProvider with Provider
#17 Connect login to Firebase Auth
#18 Connect register to Firebase Auth
#19 Connect forgot password flow
#20 Splash screen and auth redirect
```

## Sprint 2 — Gün 8–10

```
#22 UserProfile model
#23 University and department models
#24 ProfileService for Firestore
#25 Profile completion screen UI
#26 University selection from static list
#27 Department input and creation request UI
#28 Save user profile to Firestore
#29 Profile completion check after login
#32 Main home shell with bottom navigation
```

## Sprint 2 — Gün 11–14

```
#33 Post model
#34 FeedService for posts
#35 Post card component
#36 Feed list screen
#37 Text post form
#38 Save text post to Firestore
#42 Like and unlike feature
#43 Report model
#44 ReportService
#45 Report post UI flow
#65 Firebase Messaging setup
#66 Save FCM token to user profile
#72 README for mobile setup
#73 MVP smoke test checklist
```

## MVP'de Olmayanlar

Yorum sistemi, takip, DM, anonim paylaşım, topluluk sayfaları, edu mail doğrulama, AI not özeti, ödeme sistemi.

Detay: [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) — Bölüm 10

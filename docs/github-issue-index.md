# GitHub Issue Index

Bu dosya GitHub issue numaralarını plan dokümanı numaralarıyla eşleştirir.

## Önemli Kural

PR açarken **GitHub issue numarasını** kullan:

```md
Closes #1
```

Plan dokümanındaki `#14` gibi numaraları **kullanma**.

## Eşleştirme Formülü

```
Plan dokümanı # = GitHub # + 13
GitHub # = Plan dokümanı # - 13
```

## M0 — Setup (Tamamlandı, Kapalı)

| GitHub # | Plan Doc # | Başlık | Durum |
|----------|------------|--------|-------|
| #74 | #1 | Initialize Flutter project | Kapalı |
| #75 | #2 | Add base folder architecture | Kapalı |
| #76 | #3 | Add project documentation files | Kapalı |
| #77 | #4 | Add GitHub issue templates | Kapalı |
| #78 | #5 | Add pull request template | Kapalı |
| #79 | #6 | Add CODEOWNERS file | Kapalı |
| #80 | #7 | Add Flutter analyze GitHub Action | Kapalı |
| #81 | #8 | Add Flutter test GitHub Action | Kapalı |
| #82 | #9 | Add PR target branch guard | Kapalı |
| #83 | #10 | Add issue reference checker | Kapalı |
| #84 | #11 | Add changed files limit checker | Kapalı |
| #85 | #12 | Add forbidden secrets file checker | Kapalı |
| #86 | #13 | Add console/debug output checker | Kapalı |

## M1 — Theme, Routing & Shared UI

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #1 | #14 | Add app color palette and theme constants |
| #2 | #15 | Apply global app theme |
| #3 | #16 | Add shared button components |
| #4 | #17 | Add shared text input components |
| #5 | #18 | Add loading, empty and error state widgets |
| #6 | #19 | Add app routing structure |

## M2 — Firebase Foundation

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #7 | #20 | Add Firebase dependencies |
| #8 | #21 | Configure Firebase initialization |
| #9 | #22 | Add environment example file |
| #10 | #23 | Add Firestore service base class |

## M3 — Auth

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #11 | #24 | Create login screen UI |
| #12 | #25 | Create register screen UI |
| #13 | #26 | Create forgot password screen UI |
| #14 | #27 | Add auth form validation |
| #15 | #28 | Create AuthService with Firebase Auth |
| #16 | #29 | Add AuthProvider with Provider package |
| #17 | #30 | Connect login screen to Firebase Auth |
| #18 | #31 | Connect register screen to Firebase Auth |
| #19 | #32 | Connect forgot password flow |
| #20 | #33 | Add splash screen and auth redirect logic |
| #21 | #34 | Add logout functionality |

## M4 — Profile

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #22 | #35 | Create UserProfile model |
| #23 | #36 | Create university and department models |
| #24 | #37 | Create ProfileService for Firestore users |
| #25 | #38 | Create profile completion screen UI |
| #26 | #39 | Add university selection from static seed list |
| #27 | #40 | Add department input and creation request logic UI |
| #28 | #41 | Save completed user profile to Firestore |
| #29 | #42 | Add profile completion check after login |
| #30 | #43 | Create public profile screen |
| #31 | #44 | Add edit profile screen |

## M5 — Home Navigation

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #32 | #45 | Create main home shell with bottom navigation |

## M6 — Feed & Posts

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #33 | #46 | Create Post model |
| #34 | #47 | Create FeedService for posts |
| #35 | #48 | Create post card component |
| #36 | #49 | Create feed list screen |
| #37 | #50 | Create text post form |
| #38 | #51 | Save text post to Firestore |
| #39 | #52 | Add image picker for post creation |
| #40 | #53 | Create Cloudflare R2 upload service placeholder |
| #41 | #54 | Connect image post flow with temporary mock upload |
| #42 | #55 | Add like and unlike feature for posts |

## M7 — Reports

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #43 | #56 | Create Report model |
| #44 | #57 | Create ReportService |
| #45 | #58 | Add report post UI flow |

## M8 — Courses

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #46 | #59 | Create Course model |
| #47 | #60 | Create CourseMaterial model |
| #48 | #61 | Create CourseService |
| #49 | #62 | Create course list screen |
| #50 | #63 | Connect course list to Firestore |
| #51 | #64 | Create course detail screen |
| #52 | #65 | Create pending course creation form |
| #53 | #66 | Create material upload form UI |
| #54 | #67 | Add file picker for course materials |
| #55 | #68 | Save pending course material with mock upload |
| #56 | #69 | List approved course materials on course detail |
| #57 | #70 | Add report material feature |

## M9 — Events

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #58 | #71 | Create Event model |
| #59 | #72 | Create EventService |
| #60 | #73 | Create event list screen |
| #61 | #74 | Connect event list to Firestore |
| #62 | #75 | Create event detail screen |
| #63 | #76 | Create pending event creation form |
| #64 | #77 | Add report event feature |

## M10 — Notifications

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #65 | #78 | Add Firebase Messaging setup |
| #66 | #79 | Save FCM token to user profile |
| #67 | #80 | Add in-app notification handling UI |

## M11 — Moderation

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #68 | #81 | Add banned user check after login |
| #69 | #82 | Add action guard for banned users |

## M12 — Polish

| GitHub # | Plan Doc # | Başlık |
|----------|------------|--------|
| #70 | #83 | Add empty states for all MVP screens |
| #71 | #84 | Add global error handling helper |
| #72 | #85 | Add README for mobile setup |
| #73 | #86 | Add MVP smoke test checklist |

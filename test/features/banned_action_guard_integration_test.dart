// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uniz_mobile/core/services/banned_action_guard.dart';
import 'package:uniz_mobile/features/auth/providers/auth_provider.dart';
import 'package:uniz_mobile/features/auth/services/auth_service.dart';
import 'package:uniz_mobile/features/courses/screens/suggest_course_screen.dart';
import 'package:uniz_mobile/features/courses/screens/upload_material_screen.dart';
import 'package:uniz_mobile/features/courses/services/course_suggestion_service.dart';
import 'package:uniz_mobile/features/events/models/event_model.dart';
import 'package:uniz_mobile/features/events/screens/create_event_screen.dart';
import 'package:uniz_mobile/features/events/services/event_service.dart';
import 'package:uniz_mobile/features/feed/models/feed_post.dart';
import 'package:uniz_mobile/features/feed/screens/create_text_post_screen.dart';
import 'package:uniz_mobile/features/feed/services/feed_service.dart';
import 'package:uniz_mobile/features/feed/services/post_like_service.dart';
import 'package:uniz_mobile/features/feed/widgets/post_like_button.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';
import 'package:uniz_mobile/features/reports/models/report_model.dart';
import 'package:uniz_mobile/features/reports/models/report_reason.dart';
import 'package:uniz_mobile/features/reports/services/report_service.dart';
import 'package:uniz_mobile/features/reports/widgets/report_bottom_sheet.dart';
import 'package:uniz_mobile/shared/widgets/buttons/primary_button.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? displayName;

  FakeUser({required this.uid, this.displayName = 'Banned Student'});
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final User? _user;

  FakeFirebaseAuth({User? user}) : _user = user;

  @override
  User? get currentUser => _user;
}

class FakeAuthService extends Fake implements AuthService {
  final User? _user;

  FakeAuthService({User? user}) : _user = user;

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);
}

class FakeProfileServiceForGuard extends Fake implements ProfileService {
  bool isBannedValue = true;

  FakeProfileServiceForGuard({this.isBannedValue = true});

  @override
  Future<bool> isUserBanned(String userId) async => isBannedValue;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      fullName: 'Banned Student',
      email: 'banned@uniz.app',
      universityId: 'itu',
      universityName: 'İTÜ',
      departmentId: 'cs',
      departmentName: 'Bilgisayar Müh.',
      classYear: 3,
      expectedGraduationYear: 2027,
      role: UserRole.community,
      isBanned: isBannedValue,
    );
  }
}

class FakeReportService extends Fake implements ReportService {
  int createReportCallCount = 0;

  @override
  Future<void> createReport(ReportModel report) async {
    createReportCallCount++;
  }
}

class FakePostLikeService extends Fake implements PostLikeService {
  int toggleCallCount = 0;

  @override
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    toggleCallCount++;
    return true;
  }

  @override
  Future<bool> isPostLiked({
    required String postId,
    required String userId,
  }) async {
    return false;
  }
}

class FakeCourseSuggestionService extends Fake implements CourseSuggestionService {
  int suggestCourseCallCount = 0;

  @override
  Future<void> suggestCourse({
    required String userId,
    required String courseCode,
    required String courseName,
    required String department,
    String? description,
  }) async {
    suggestCourseCallCount++;
  }
}

class FakeFeedService extends Fake implements FeedService {
  int createPostCallCount = 0;

  @override
  Future<String> createPost(FeedPost post) async {
    createPostCallCount++;
    return 'new_post_id';
  }
}

class FakeEventService extends Fake implements EventService {
  int createPendingEventCallCount = 0;

  @override
  Future<void> createPendingEvent(EventModel event) async {
    createPendingEventCallCount++;
  }
}

void main() {
  late FakeUser testUser;
  late FakeFirebaseAuth fakeAuth;
  late FakeProfileServiceForGuard fakeProfileService;

  setUp(() {
    testUser = FakeUser(uid: 'banned_user_123');
    fakeAuth = FakeFirebaseAuth(user: testUser);
    fakeProfileService = FakeProfileServiceForGuard(isBannedValue: true);
    BannedActionGuard.mockProfileService = fakeProfileService;
    BannedActionGuard.mockAuth = fakeAuth;
  });

  tearDown(() {
    BannedActionGuard.mockProfileService = null;
    BannedActionGuard.mockAuth = null;
  });

  group('Kritik Aksiyonlar Ban Koruması Entegrasyon Testleri (Issue #69)', () {
    testWidgets('1. Like atma: Banlı kullanıcı beğeni yapamaz, standart mesaj gösterilir',
        (WidgetTester tester) async {
      final fakeLikeService = FakePostLikeService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostLikeButton(
              postId: 'post_123',
              userId: 'banned_user_123',
              initialLikeCount: 5,
              initialIsLiked: false,
              postLikeService: fakeLikeService,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PostLikeButton));
      await tester.pump();

      expect(fakeLikeService.toggleCallCount, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });

    testWidgets('2. Rapor gönderme: Banlı kullanıcı rapor submit edemez',
        (WidgetTester tester) async {
      final fakeReportService = FakeReportService();
      final fakeAuthService = FakeAuthService(user: testUser);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: fakeAuthService),
          child: MaterialApp(
            home: Scaffold(
              body: ReportBottomSheet(
                postId: 'post_123',
                reportService: fakeReportService,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Bir sebep seç
      await tester.tap(find.text(ReportReason.spamMisleading.label));
      await tester.pump();

      // Raporla butonuna bas
      final submitButton = find.widgetWithText(FilledButton, 'Raporla');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();

      expect(fakeReportService.createReportCallCount, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });

    testWidgets('3. Ders ekleme: Banlı kullanıcı ders önerisi gönderemez',
        (WidgetTester tester) async {
      final fakeCourseService = FakeCourseSuggestionService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestCourseScreen(
              authInstance: fakeAuth,
              service: fakeCourseService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Gönder butonuna bas
      final submitFinder =
          find.widgetWithText(PrimaryButton, 'Öneriyi Gönder');
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pump();

      expect(fakeCourseService.suggestCourseCallCount, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });

    testWidgets('4. Materyal yükleme: Banlı kullanıcı materyal yükleyemez',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UploadMaterialScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Telif hakkı onay kutusunu işaretle
      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Yükle butonunu bul ve tıkla
      final uploadButton = find.widgetWithText(PrimaryButton, 'Yükle');
      await tester.ensureVisible(uploadButton);
      await tester.tap(uploadButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });

    testWidgets('5. Etkinlik oluşturma: Banlı kullanıcı etkinlik formu gönderemez',
        (WidgetTester tester) async {
      final fakeEventService = FakeEventService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreateEventScreen(
              authInstance: fakeAuth,
              profileService: fakeProfileService,
              eventService: fakeEventService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submitFinder =
          find.widgetWithText(PrimaryButton, 'Etkinlik Talebi Gönder');
      expect(submitFinder, findsOneWidget);

      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pump();

      expect(fakeEventService.createPendingEventCallCount, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });

    testWidgets('6. Post oluşturma: Banlı kullanıcı gönderi paylaşamaz',
        (WidgetTester tester) async {
      final fakeFeedService = FakeFeedService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreateTextPostScreen(
              authInstance: fakeAuth,
              profileService: fakeProfileService,
              feedService: fakeFeedService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Metin gir
      await tester.enterText(
        find.byType(TextFormField).first,
        'Merhaba kampüs!',
      );
      await tester.pump();

      // Paylaş butonuna bas
      final shareButton = find.widgetWithText(PrimaryButton, 'Paylaş');
      expect(shareButton, findsOneWidget);
      await tester.tap(shareButton);
      await tester.pump();

      expect(fakeFeedService.createPostCallCount, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });
  });
}

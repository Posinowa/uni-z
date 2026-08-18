// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/core/routing/app_routes.dart';
import 'package:uniz_mobile/features/auth/screens/splash_screen.dart';
import 'package:uniz_mobile/features/auth/services/auth_service.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';
import 'package:uniz_mobile/shared/widgets/states/app_error_state.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  FakeUser({required this.uid});
}

class FakeAuthService extends Fake implements AuthService {
  User? _currentUser;
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  bool signOutCalled = false;

  FakeAuthService({User? initialUser}) : _currentUser = initialUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _currentUser = null;
    _controller.add(null);
  }
}

class FakeProfileService extends Fake implements ProfileService {
  UserProfile? returnProfile;
  bool shouldThrow = false;
  int getUserProfileCallCount = 0;

  FakeProfileService({this.returnProfile, this.shouldThrow = false});

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    getUserProfileCallCount++;
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Firestore read error',
      );
    }
    return returnProfile;
  }
}

void main() {
  final testProfile = UserProfile(
    id: 'user_123',
    fullName: 'Ahmet Yılmaz',
    email: 'ahmet@uniz.app',
    universityId: 'itu',
    universityName: 'İTÜ',
    departmentId: 'cs',
    departmentName: 'Bilgisayar Müh.',
    classYear: 3,
    expectedGraduationYear: 2027,
    role: UserRole.student,
  );

  Widget createTestWidget({
    required AuthService authService,
    required ProfileService profileService,
    NavigatorObserver? observer,
  }) {
    return MaterialApp(
      navigatorObservers: observer != null ? [observer] : [],
      routes: {
        AppRoutes.splash: (_) => SplashScreen(
              authService: authService,
              profileService: profileService,
            ),
        AppRoutes.login: (_) => const Scaffold(body: Text('Login Screen Test')),
        AppRoutes.profileCompletion: (_) =>
            const Scaffold(body: Text('Profile Completion Test')),
        AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen Test')),
      },
      initialRoute: AppRoutes.splash,
    );
  }

  group('SplashScreen Yönlendirme ve Hata Yönetimi Testleri', () {
    testWidgets('Giriş yapmamış kullanıcıyı /login ekranına yönlendirir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService(initialUser: null);
      final fakeProfile = FakeProfileService();

      await tester.pumpWidget(
        createTestWidget(authService: fakeAuth, profileService: fakeProfile),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login Screen Test'), findsOneWidget);
    });

    testWidgets(
        'Giriş yapmış ve profili eksik kullanıcıyı /profile-completion ekranına yönlendirir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService(initialUser: FakeUser(uid: 'user_123'));
      final fakeProfile = FakeProfileService(returnProfile: null);

      await tester.pumpWidget(
        createTestWidget(authService: fakeAuth, profileService: fakeProfile),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile Completion Test'), findsOneWidget);
    });

    testWidgets(
        'Giriş yapmış ve profili tam olan kullanıcıyı /home ekranına yönlendirir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService(initialUser: FakeUser(uid: 'user_123'));
      final fakeProfile = FakeProfileService(returnProfile: testProfile);

      await tester.pumpWidget(
        createTestWidget(authService: fakeAuth, profileService: fakeProfile),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Test'), findsOneWidget);
    });

    testWidgets(
        'Firestore hatasında kullanıcıyı login ekranına atmadan hata durumu ve SnackBar gösterir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService(initialUser: FakeUser(uid: 'user_123'));
      final fakeProfile = FakeProfileService(shouldThrow: true);

      await tester.pumpWidget(
        createTestWidget(authService: fakeAuth, profileService: fakeProfile),
      );
      await tester.pumpAndSettle();

      // Login ekranına körlemesine yönlendirilmediğini doğrula
      expect(find.text('Login Screen Test'), findsNothing);

      // Hata UI ve SnackBar'ın görüntülendiğini doğrula
      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.text('Profil Alınamadı'), findsOneWidget);
      expect(
        find.text('Profil bilgisi alınamadı. Lütfen tekrar deneyin.'),
        findsWidgets,
      );
      expect(find.text('Tekrar Dene'), findsOneWidget);
      expect(find.text('Çıkış Yap ve Giriş Ekranına Dön'), findsOneWidget);
    });

    testWidgets('Hata durumunda Tekrar Dene butonuna basıldığında tekrar profil çeker',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService(initialUser: FakeUser(uid: 'user_123'));
      final fakeProfile = FakeProfileService(shouldThrow: true);

      await tester.pumpWidget(
        createTestWidget(authService: fakeAuth, profileService: fakeProfile),
      );
      await tester.pumpAndSettle();

      expect(fakeProfile.getUserProfileCallCount, 1);
      expect(find.byType(AppErrorState), findsOneWidget);

      // Hatayı çöz
      fakeProfile.shouldThrow = false;
      fakeProfile.returnProfile = testProfile;

      // Tekrar dene butonuna tıkla
      await tester.tap(find.text('Tekrar Dene'));
      await tester.pumpAndSettle();

      expect(fakeProfile.getUserProfileCallCount, 2);
      expect(find.text('Home Screen Test'), findsOneWidget);
    });

    testWidgets(
        'Hata durumunda Çıkış Yap butonuna basıldığında oturumu kapatıp /login ekranına yönlendirir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService(initialUser: FakeUser(uid: 'user_123'));
      final fakeProfile = FakeProfileService(shouldThrow: true);

      await tester.pumpWidget(
        createTestWidget(authService: fakeAuth, profileService: fakeProfile),
      );
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, isFalse);

      // Çıkış yap butonuna tıkla
      await tester.tap(find.text('Çıkış Yap ve Giriş Ekranına Dön'));
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, isTrue);
      expect(find.text('Login Screen Test'), findsOneWidget);
    });
  });
}

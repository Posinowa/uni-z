// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uniz_mobile/core/routing/app_routes.dart';
import 'package:uniz_mobile/features/auth/providers/auth_provider.dart';
import 'package:uniz_mobile/features/auth/screens/login_screen.dart';
import 'package:uniz_mobile/features/auth/services/auth_service.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';
import 'package:uniz_mobile/shared/widgets/buttons/primary_button.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  FakeUser({required this.uid});
}

class FakeAuthService extends Fake implements AuthService {
  User? _currentUser;
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  bool shouldFailSignIn = false;
  String? signInErrorMessage;

  FakeAuthService({User? initialUser}) : _currentUser = initialUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (shouldFailSignIn) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: signInErrorMessage ?? 'Kullanıcı bulunamadı.',
      );
    }
    _currentUser = FakeUser(uid: 'user_123');
    _controller.add(_currentUser);
    return FakeUserCredential(_currentUser!);
  }
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User user;

  FakeUserCredential(this.user);
}

class FakeProfileService extends Fake implements ProfileService {
  UserProfile? returnProfile;
  bool shouldThrow = false;

  FakeProfileService({this.returnProfile, this.shouldThrow = false});

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
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

  Widget createLoginTestWidget({
    required FakeAuthService authService,
    required FakeProfileService profileService,
  }) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(authService: authService),
      child: MaterialApp(
        routes: {
          AppRoutes.login: (_) => LoginScreen(profileService: profileService),
          AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen Test')),
          AppRoutes.profileCompletion: (_) =>
              const Scaffold(body: Text('Profile Completion Test')),
          AppRoutes.forgotPassword: (_) =>
              const Scaffold(body: Text('Forgot Password Test')),
          AppRoutes.register: (_) =>
              const Scaffold(body: Text('Register Screen Test')),
        },
        initialRoute: AppRoutes.login,
      ),
    );
  }

  group('LoginScreen Yönlendirme ve Profil Kontrolü Testleri', () {
    testWidgets(
        'Giriş başarılı ve profili tam olan kullanıcıyı /home ekranına yönlendirir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      final fakeProfile = FakeProfileService(returnProfile: testProfile);

      await tester.pumpWidget(
        createLoginTestWidget(
          authService: fakeAuth,
          profileService: fakeProfile,
        ),
      );
      await tester.pumpAndSettle();

      // Formu doldur
      await tester.enterText(
        find.byType(TextFormField).first,
        'ahmet@uniz.app',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Giriş Yap butonuna bas
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Test'), findsOneWidget);
    });

    testWidgets(
        'Giriş başarılı fakat profili eksik kullanıcıyı /profile-completion ekranına yönlendirir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      final fakeProfile = FakeProfileService(returnProfile: null);

      await tester.pumpWidget(
        createLoginTestWidget(
          authService: fakeAuth,
          profileService: fakeProfile,
        ),
      );
      await tester.pumpAndSettle();

      // Formu doldur
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-posta'),
        'ahmet@uniz.app',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Giriş Yap butonuna bas
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Profile Completion Test'), findsOneWidget);
    });

    testWidgets(
        'Giriş başarılı fakat profil çekilirken Firestore hatası olursa SnackBar gösterir',
        (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      final fakeProfile = FakeProfileService(shouldThrow: true);

      await tester.pumpWidget(
        createLoginTestWidget(
          authService: fakeAuth,
          profileService: fakeProfile,
        ),
      );
      await tester.pumpAndSettle();

      // Formu doldur
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-posta'),
        'ahmet@uniz.app',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Giriş Yap butonuna bas
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // SnackBar görüntülendiğini doğrula
      expect(
        find.text('Profil bilgisi alınamadı. Lütfen tekrar deneyin.'),
        findsOneWidget,
      );
      // Ekranın patlamadığını ve login formunun hâlâ ekranda olduğunu doğrula
      expect(find.text('Giriş Yap'), findsWidgets);
    });
  });
}

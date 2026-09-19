// ignore_for_file: subtype_of_sealed_class

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/core/services/banned_action_guard.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';

class FakeProfileService extends Fake implements ProfileService {
  bool isBannedValue = false;
  bool shouldThrow = false;
  int isUserBannedCallCount = 0;

  FakeProfileService({this.isBannedValue = false, this.shouldThrow = false});

  @override
  Future<bool> isUserBanned(String userId) async {
    isUserBannedCallCount++;
    if (shouldThrow) {
      throw Exception('Firestore network error');
    }
    return isBannedValue;
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      fullName: 'Test User',
      email: 'test@uniz.app',
      universityId: 'itu',
      universityName: 'İTÜ',
      departmentId: 'cs',
      departmentName: 'Bilgisayar Müh.',
      classYear: 3,
      expectedGraduationYear: 2027,
      role: UserRole.student,
      isBanned: isBannedValue,
    );
  }
}

void main() {
  tearDown(() {
    BannedActionGuard.mockProfileService = null;
  });

  group('BannedActionGuard Unit Testleri', () {
    test('isBanned boş userId için anında false döner', () async {
      final fakeProfileService = FakeProfileService(isBannedValue: true);

      final resultEmpty = await BannedActionGuard.isBanned(
        userId: '',
        profileService: fakeProfileService,
      );
      expect(resultEmpty, isFalse);
      expect(fakeProfileService.isUserBannedCallCount, 0);

      final resultWhitespace = await BannedActionGuard.isBanned(
        userId: '   ',
        profileService: fakeProfileService,
      );
      expect(resultWhitespace, isFalse);
      expect(fakeProfileService.isUserBannedCallCount, 0);
    });

    test('isBanned banlı olmayan kullanıcı için false döner', () async {
      final fakeProfileService = FakeProfileService(isBannedValue: false);

      final result = await BannedActionGuard.isBanned(
        userId: 'user_active',
        profileService: fakeProfileService,
      );
      expect(result, isFalse);
      expect(fakeProfileService.isUserBannedCallCount, 1);
    });

    test('isBanned banlı kullanıcı için true döner', () async {
      final fakeProfileService = FakeProfileService(isBannedValue: true);

      final result = await BannedActionGuard.isBanned(
        userId: 'user_banned',
        profileService: fakeProfileService,
      );
      expect(result, isTrue);
      expect(fakeProfileService.isUserBannedCallCount, 1);
    });

    test('isBanned hata durumunda güvenle false döner', () async {
      final fakeProfileService = FakeProfileService(shouldThrow: true);

      final result = await BannedActionGuard.isBanned(
        userId: 'user_error',
        profileService: fakeProfileService,
      );
      expect(result, isFalse);
    });

    test('mockProfileService statik alanı aktif olduğunda kullanılır', () async {
      final fakeProfileService = FakeProfileService(isBannedValue: true);
      BannedActionGuard.mockProfileService = fakeProfileService;

      final result = await BannedActionGuard.isBanned(userId: 'user_123');
      expect(result, isTrue);
      expect(fakeProfileService.isUserBannedCallCount, 1);
    });
  });

  group('BannedActionGuard Widget ve SnackBar Testleri', () {
    testWidgets('check banlı olmayan kullanıcıya izin verir (true döner, SnackBar çıkmaz)',
        (WidgetTester tester) async {
      final fakeProfileService = FakeProfileService(isBannedValue: false);
      bool? checkResult;
      bool onBannedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  checkResult = await BannedActionGuard.check(
                    context,
                    userId: 'user_123',
                    profileService: fakeProfileService,
                    onBanned: () {
                      onBannedCalled = true;
                    },
                  );
                },
                child: const Text('Action'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(checkResult, isTrue);
      expect(onBannedCalled, isFalse);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets(
        'check banlı kullanıcıyı engeller (false döner, standart SnackBar ve callback tetiklenir)',
        (WidgetTester tester) async {
      final fakeProfileService = FakeProfileService(isBannedValue: true);
      bool? checkResult;
      bool onBannedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  checkResult = await BannedActionGuard.check(
                    context,
                    userId: 'user_123',
                    profileService: fakeProfileService,
                    onBanned: () {
                      onBannedCalled = true;
                    },
                  );
                },
                child: const Text('Action'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Action'));
      await tester.pump();

      expect(checkResult, isFalse);
      expect(onBannedCalled, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          'Hesabınız geçici olarak kısıtlanmıştır. Bu işlemi şu anda gerçekleştiremezsiniz.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('showBannedSnackBar doğrudan çağrıldığında standart mesajı gösterir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => BannedActionGuard.showBannedSnackBar(context),
                child: const Text('Show SnackBar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(BannedActionGuard.bannedMessage),
        findsOneWidget,
      );
    });
  });
}

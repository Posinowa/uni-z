// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/screens/edit_profile_screen.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';
import 'package:uniz_mobile/shared/widgets/buttons/primary_button.dart';

class FakeProfileService extends Fake implements ProfileService {
  UserProfile? lastUpdatedProfile;
  bool shouldThrow = false;

  FakeProfileService({this.shouldThrow = false});

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Update error',
      );
    }
    lastUpdatedProfile = profile;
  }
}

void main() {
  final sampleProfile = UserProfile(
    id: 'user_123',
    fullName: 'Ahmet Yılmaz',
    email: 'ahmet@uniz.app',
    phone: '05551112233',
    universityId: 'uni_itu',
    universityName: 'İSTANBUL TEKNİK ÜNİVERSİTESİ',
    departmentId: 'dep_cs',
    departmentName: 'Bilgisayar Mühendisliği',
    classYear: 3,
    expectedGraduationYear: 2028,
    role: UserRole.student,
  );

  Widget createTestWidget({
    required UserProfile profile,
    required ProfileService profileService,
  }) {
    return MaterialApp(
      home: EditProfileScreen(
        profile: profile,
        profileService: profileService,
      ),
    );
  }

  group('EditProfileScreen Testleri', () {
    testWidgets('Profil bilgileri form alanlarına doğru yüklenir',
        (WidgetTester tester) async {
      final fakeService = FakeProfileService();

      await tester.pumpWidget(
        createTestWidget(
          profile: sampleProfile,
          profileService: fakeService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profili Düzenle'), findsOneWidget);
      expect(find.text('Ahmet Yılmaz'), findsOneWidget);
      expect(find.text('05551112233'), findsOneWidget);
      expect(find.text('3. Sınıf'), findsOneWidget);
      expect(find.text('2028'), findsOneWidget);
    });

    testWidgets(
        'Blocker 1 Testi: Telefon temizlendiğinde phone: null olarak güncellenir',
        (WidgetTester tester) async {
      final fakeService = FakeProfileService();

      await tester.pumpWidget(
        createTestWidget(
          profile: sampleProfile,
          profileService: fakeService,
        ),
      );
      await tester.pumpAndSettle();

      // Telefon alanını temizle
      final phoneField = find.widgetWithText(TextFormField, '05551112233');
      await tester.enterText(phoneField, '');
      await tester.pumpAndSettle();

      // Kaydet butonuna bas
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(fakeService.lastUpdatedProfile, isNotNull);
      expect(fakeService.lastUpdatedProfile!.phone, isNull);
      expect(fakeService.lastUpdatedProfile!.fullName, 'Ahmet Yılmaz');
    });

    testWidgets(
        'Blocker 2 Testi: Geçmiş mezuniyet yılına sahip profil dropdown crash oluşturmaz',
        (WidgetTester tester) async {
      final fakeService = FakeProfileService();
      final pastYearProfile = sampleProfile.copyWith(
        expectedGraduationYear: 2023, // Mevcut yıldan önceki geçmiş bir yıl
        classYear: 7, // Standart 1-6 dışı sınıf
      );

      await tester.pumpWidget(
        createTestWidget(
          profile: pastYearProfile,
          profileService: fakeService,
        ),
      );
      await tester.pumpAndSettle();

      // Assert/crash olmadan ekranın açıldığını ve değerlerin dropdown'da yer aldığını doğrula
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('7. Sınıf'), findsOneWidget);
    });

    testWidgets('İsim güncellendiğinde profil başarıyla güncellenir',
        (WidgetTester tester) async {
      final fakeService = FakeProfileService();

      await tester.pumpWidget(
        createTestWidget(
          profile: sampleProfile,
          profileService: fakeService,
        ),
      );
      await tester.pumpAndSettle();

      // İsmi güncelle
      final nameField = find.widgetWithText(TextFormField, 'Ahmet Yılmaz');
      await tester.enterText(nameField, 'Mehmet Yılmaz');
      await tester.pumpAndSettle();

      // Kaydet butonuna bas
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(fakeService.lastUpdatedProfile, isNotNull);
      expect(fakeService.lastUpdatedProfile!.fullName, 'Mehmet Yılmaz');
      expect(fakeService.lastUpdatedProfile!.phone, '05551112233');
    });

    testWidgets('Firestore güncelleme hatasında kullanıcıya hata mesajı gösterilir',
        (WidgetTester tester) async {
      final fakeService = FakeProfileService(shouldThrow: true);

      await tester.pumpWidget(
        createTestWidget(
          profile: sampleProfile,
          profileService: fakeService,
        ),
      );
      await tester.pumpAndSettle();

      // Kaydet butonuna bas
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Profil güncellenemedi. Lütfen tekrar deneyin.'),
        findsOneWidget,
      );
    });
  });
}

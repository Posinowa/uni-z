// ignore_for_file: subtype_of_sealed_class

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uniz_mobile/features/auth/providers/auth_provider.dart';
import 'package:uniz_mobile/features/auth/services/auth_service.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/screens/settings_screen.dart';
import 'package:uniz_mobile/features/profile/widgets/logout_button.dart';

class FakeAuthService extends Fake implements AuthService {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(null);
}

void main() {
  final sampleProfile = UserProfile(
    id: 'user_123',
    fullName: 'Ahmet Yılmaz',
    email: 'ahmet@uniz.app',
    phone: '05551112233',
    universityId: 'uni_ostim',
    universityName: 'OSTİM Teknik Üniversitesi',
    departmentId: 'dep_cs',
    departmentName: 'Yazılım Mühendisliği',
    classYear: 2,
    expectedGraduationYear: 2028,
    role: UserRole.student,
  );

  testWidgets('SettingsScreen temel bölümleri ve seçenekleri gösterir',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(authService: FakeAuthService()),
        child: MaterialApp(
          home: SettingsScreen(profile: sampleProfile),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Hesap'), findsOneWidget);
    expect(find.text('Profili Düzenle'), findsOneWidget);
    expect(find.text('Hesap Yönetimi'), findsOneWidget);
    expect(find.text('Tercihler'), findsOneWidget);
    expect(find.text('Bildirim Tercihleri'), findsOneWidget);
    expect(find.text('Görünüm'), findsOneWidget);
    expect(find.text('Dil'), findsOneWidget);
    expect(find.byType(LogoutButton), findsOneWidget);
  });
}

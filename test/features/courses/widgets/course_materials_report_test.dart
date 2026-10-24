// ignore_for_file: subtype_of_sealed_class

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uniz_mobile/features/auth/providers/auth_provider.dart';
import 'package:uniz_mobile/features/auth/services/auth_service.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';
import 'package:uniz_mobile/features/reports/models/report_model.dart';
import 'package:uniz_mobile/features/reports/models/report_reason.dart';
import 'package:uniz_mobile/features/reports/models/report_target_type.dart';
import 'package:uniz_mobile/features/reports/services/report_service.dart';
import 'package:uniz_mobile/features/reports/widgets/report_bottom_sheet.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? displayName;

  FakeUser({required this.uid, this.displayName = 'Test Student'});
}

class FakeAuthService extends Fake implements AuthService {
  final User? _user;

  FakeAuthService({User? user}) : _user = user;

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);
}

class FakeProfileService extends Fake implements ProfileService {
  @override
  Future<bool> isUserBanned(String userId) async => false;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      fullName: 'Test Student',
      email: 'student@uniz.app',
      universityId: 'itu',
      universityName: 'İTÜ',
      departmentId: 'cs',
      departmentName: 'Bilgisayar Müh.',
      classYear: 3,
      expectedGraduationYear: 2027,
      role: UserRole.student,
      isBanned: false,
    );
  }
}

class FakeReportService extends Fake implements ReportService {
  final List<ReportModel> createdReports = [];
  bool duplicateOnPreCheck = false;
  bool throwStateErrorOnCreate = false;

  @override
  Future<bool> hasUserReported({
    required String targetType,
    required String targetId,
    required String userId,
  }) async {
    return duplicateOnPreCheck;
  }

  @override
  Future<void> createReport(ReportModel report) async {
    if (throwStateErrorOnCreate) {
      throw StateError(
        'Bu içerik zaten raporlandı. Aynı içerik tekrar raporlanamaz.',
      );
    }
    createdReports.add(report);
  }
}

void main() {
  late FakeUser testUser;
  late FakeAuthService fakeAuthService;
  late FakeReportService fakeReportService;

  setUp(() {
    testUser = FakeUser(uid: 'user_456');
    fakeAuthService = FakeAuthService(user: testUser);
    fakeReportService = FakeReportService();
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: fakeAuthService),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('Issue #57: Material Report Flow Tests', () {
    testWidgets('1. ReportBottomSheet opens with material title and targetType', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReportBottomSheet(
            targetId: 'mat_123',
            targetType: ReportTargetType.material,
            reportService: fakeReportService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Başlık 'Materyali Raporla' olarak gözükmeli
      expect(find.text('Materyali Raporla'), findsOneWidget);
      expect(find.text('Raporla'), findsOneWidget);
    });

    testWidgets('2. Submitting material report sends ReportTargetType.material to ReportService', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReportBottomSheet(
            targetId: 'mat_123',
            targetType: ReportTargetType.material,
            reportService: fakeReportService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Sebep seç
      await tester.tap(find.text(ReportReason.copyrightViolation.label));
      await tester.pump();

      // Raporla butonuna tıkla
      await tester.tap(find.text('Raporla'));
      await tester.pumpAndSettle();

      // Servise giden rapor kontrolü
      expect(fakeReportService.createdReports.length, 1);
      final report = fakeReportService.createdReports.first;
      expect(report.targetId, 'mat_123');
      expect(report.targetType, ReportTargetType.material);
      expect(report.reportedBy, 'user_456');
      expect(report.reason, ReportReason.copyrightViolation.value);
    });

    testWidgets('3. Duplicate report pre-check prevents opening sheet and shows snackbar', (tester) async {
      fakeReportService.duplicateOnPreCheck = true;

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ReportBottomSheet.show(
                    context,
                    targetId: 'mat_123',
                    targetType: ReportTargetType.material,
                    reportService: fakeReportService,
                  );
                },
                child: const Text('Open Report'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Report'));
      await tester.pumpAndSettle();

      // Modal açılmamalı, doğrudan SnackBar uyarısı gösterilmeli
      expect(find.text('Materyali Raporla'), findsNothing);
      expect(find.text('Bu materyali daha önce raporladınız.'), findsOneWidget);
    });

    testWidgets('4. If createReport throws StateError, error snackbar is displayed', (tester) async {
      fakeReportService.throwStateErrorOnCreate = true;

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ReportBottomSheet.show(
                    context,
                    targetId: 'mat_123',
                    targetType: ReportTargetType.material,
                    reportService: fakeReportService,
                  );
                },
                child: const Text('Open Report'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Report'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ReportReason.spamMisleading.label));
      await tester.pump();

      await tester.tap(find.text('Raporla'));
      await tester.pumpAndSettle();

      expect(
        find.text('Bu içerik zaten raporlandı. Aynı içerik tekrar raporlanamaz.'),
        findsOneWidget,
      );
    });
  });
}

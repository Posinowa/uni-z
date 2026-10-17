import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/core/routing/app_routes.dart';
import 'package:uniz_mobile/features/auth/screens/banned_user_screen.dart';
import 'package:uniz_mobile/shared/widgets/buttons/primary_button.dart';

void main() {
  Widget createTestWidget({
    String? banReason,
    VoidCallback? onLogout,
  }) {
    return MaterialApp(
      routes: {
        AppRoutes.banned: (_) => BannedUserScreen(
              banReason: banReason,
              onLogout: onLogout,
            ),
        AppRoutes.login: (_) =>
            const Scaffold(body: Text('Login Screen Test')),
      },
      initialRoute: AppRoutes.banned,
    );
  }

  group('BannedUserScreen Testleri', () {
    testWidgets('Kısıtlama başlığı ve kibar bilgilendirme mesajı görüntülenir',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hesabınız Kısıtlandı'), findsOneWidget);
      expect(
        find.textContaining('Topluluk kurallarımız'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    });

    testWidgets('Kısıtlanan işlemler listesi doğru görüntülenir',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Kısıtlanan İşlemler'), findsOneWidget);
      expect(find.text('İçerik ve gönderi paylaşma'), findsOneWidget);
      expect(find.text('Ders notu ve materyal yükleme'), findsOneWidget);
      expect(find.text('Gönderi ve içerikleri beğenme'), findsOneWidget);
      expect(find.text('Rapor ve talep oluşturma'), findsOneWidget);
    });

    testWidgets('Ban sebebi verildiğinde ekranda görüntülenir',
        (WidgetTester tester) async {
      const reason = 'Uygunsuz profil bilgisi ve spam içerik';
      await tester.pumpWidget(createTestWidget(banReason: reason));
      await tester.pumpAndSettle();

      expect(find.text('Kısıtlama Gerekçesi'), findsOneWidget);
      expect(find.text(reason), findsOneWidget);
    });

    testWidgets('Ban sebebi verilmediğinde gerekçe kartı gösterilmez',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(banReason: null));
      await tester.pumpAndSettle();

      expect(find.text('Kısıtlama Gerekçesi'), findsNothing);
    });

    testWidgets('Destek iletişim bilgisi gösterilir',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('destek@uniz.app'), findsOneWidget);
    });

    testWidgets('Çıkış yap butonuna basıldığında login ekranına yönlendirir',
        (WidgetTester tester) async {
      bool logoutCalled = false;
      await tester.pumpWidget(
        createTestWidget(
          onLogout: () {
            logoutCalled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final logoutButtonFinder = find.widgetWithText(PrimaryButton, 'Çıkış Yap');
      expect(logoutButtonFinder, findsOneWidget);

      await tester.ensureVisible(logoutButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(logoutButtonFinder);
      await tester.pumpAndSettle();

      expect(logoutCalled, isTrue);
      expect(find.text('Login Screen Test'), findsOneWidget);
    });

    testWidgets('PopScope canPop false olarak ayarlanmıştır',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final popScopeFinder = find.byType(PopScope);
      expect(popScopeFinder, findsOneWidget);
      final popScope = tester.widget<PopScope>(popScopeFinder);
      expect(popScope.canPop, isFalse);
    });
  });
}

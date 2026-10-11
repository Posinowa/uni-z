import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/core/constants/app_colors.dart';
import 'package:uniz_mobile/shared/widgets/states/app_empty_state.dart';

void main() {
  group('AppEmptyState Widget Testleri', () {
    testWidgets('1. Başlık, açıklama ve ikon başarıyla render edilir',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Henüz veri yok',
              description: 'Lütfen daha sonra tekrar kontrol edin.',
              icon: Icons.inbox_outlined,
            ),
          ),
        ),
      );

      expect(find.text('Henüz veri yok'), findsOneWidget);
      expect(
        find.text('Lütfen daha sonra tekrar kontrol edin.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      // Aksiyon tanımlanmadığında buton görünmemelidir
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('2. actionText ve actionIcon verildiğinde buton render edilir',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Boş Liste',
              description: 'Yeni bir öğe ekleyin.',
              icon: Icons.list_alt,
              actionText: 'Yeni Ekle',
              actionIcon: Icons.add,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Boş Liste'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Yeni Ekle'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets(
        '3. Butona tıklandığında onActionPressed callback fonksiyonu tetiklenir',
        (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Boş Durum',
              actionText: 'Tıkla',
              onActionPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      expect(wasPressed, isFalse);
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('4. actionColor parametresi butona doğru şekilde uygulanır',
        (tester) async {
      const customColor = AppColors.categoryEvents;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Etkinlik Yok',
              actionText: 'Etkinlik Ekle',
              actionIcon: Icons.add,
              actionColor: customColor,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      final button =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final foreground = button.style?.foregroundColor?.resolve({});
      final side = button.style?.side?.resolve({});

      expect(foreground, equals(customColor));
      expect(side?.color, equals(customColor));
    });

    testWidgets(
        '5. actionColor verilmediğinde varsayılan primaryIndigo rengi kullanılır',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Varsayılan Renk',
              actionText: 'Aksiyon',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      final button =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final foreground = button.style?.foregroundColor?.resolve({});
      final side = button.style?.side?.resolve({});

      expect(foreground, equals(AppColors.primaryIndigo));
      expect(side?.color, equals(AppColors.primaryIndigo));
    });
  });
}

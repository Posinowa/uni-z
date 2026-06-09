import 'package:flutter_test/flutter_test.dart';

import 'package:uniz_mobile/main.dart';

void main() {
  testWidgets('Uygulama splash ekranında başlar', (WidgetTester tester) async {
    await tester.pumpWidget(const UnizMobileApp());

    expect(find.text('Splash Screen'), findsOneWidget);
  });
}

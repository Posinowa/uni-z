import 'package:flutter_test/flutter_test.dart';

import 'package:uniz_mobile/main.dart';

void main() {
  testWidgets('Ana ekranda Uni\'z Mobile yazısı görünür', (WidgetTester tester) async {
    await tester.pumpWidget(const UnizMobileApp());

    expect(find.text("Uni'z Mobile"), findsOneWidget);
  });
}

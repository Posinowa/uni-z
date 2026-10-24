import 'package:flutter_test/flutter_test.dart';

import 'package:uniz_mobile/app/app.dart';
import 'package:uniz_mobile/core/routing/app_router.dart';

void main() {
  testWidgets('Uygulama splash ekranında başlar', (WidgetTester tester) async {
    await tester.pumpWidget(
      UnizApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );

    expect(find.text('Splash Screen'), findsOneWidget);
  });
}

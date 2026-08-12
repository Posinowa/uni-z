import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uniz_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: '1:1234567890:android:test-app-id',
        messagingSenderId: '1234567890',
        projectId: 'test-project-id',
      ),
    );
  });

  testWidgets('Uygulama başlatılırken hata vermez', (WidgetTester tester) async {
    await tester.pumpWidget(const UnizMobileApp());

    expect(find.byType(UnizMobileApp), findsOneWidget);
  });
}

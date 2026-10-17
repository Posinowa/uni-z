import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/app/app.dart';
import 'package:uniz_mobile/core/routing/app_routes.dart';
import 'package:uniz_mobile/features/notifications/services/in_app_notification_handler.dart';
import 'package:uniz_mobile/features/notifications/services/notification_service.dart';
import 'package:uniz_mobile/features/notifications/widgets/in_app_notification_snackbar.dart';
import 'package:uniz_mobile/features/notifications/widgets/notification_dialog.dart';

void main() {
  group('NotificationDialog Tests', () {
    testWidgets('Başlık ve içerik doğru şekilde gösterilir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NotificationDialog.show(
                    context,
                    title: 'Ders İptali',
                    body: 'Bugünkü Fizik dersi iptal edilmiştir.',
                  );
                },
                child: const Text('Diyaloğu Aç'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Diyaloğu Aç'));
      await tester.pumpAndSettle();

      expect(find.text('Ders İptali'), findsOneWidget);
      expect(find.text('Bugünkü Fizik dersi iptal edilmiştir.'), findsOneWidget);
      expect(find.text('Kapat'), findsOneWidget);
      expect(find.text('Görüntüle'), findsOneWidget);
    });

    testWidgets('Görüntüle butonuna tıklandığında onTap callback çağrılır',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NotificationDialog.show(
                    context,
                    title: 'Etkinlik Başladı',
                    onTap: () => tapped = true,
                  );
                },
                child: const Text('Aç'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Görüntüle'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      // Diyalog kapanmış olmalı
      expect(find.byType(NotificationDialog), findsNothing);
    });

    testWidgets('Kapat butonuna tıklandığında diyalog kapanır', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NotificationDialog.show(
                    context,
                    title: 'Duyuru',
                  );
                },
                child: const Text('Aç'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationDialog), findsOneWidget);

      await tester.tap(find.text('Kapat'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationDialog), findsNothing);
    });
  });

  group('InAppNotificationSnackBar Tests', () {
    testWidgets('SnackBar başlık ve içerik ile doğru oluşturulur ve gösterilir',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  InAppNotificationSnackBar.show(
                    context,
                    title: 'Yeni Not Yüklendi',
                    body: 'Matematik 1 vize notları yüklendi.',
                  );
                },
                child: const Text('SnackBar Göster'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SnackBar Göster'));
      await tester.pump(); // SnackBar animasyonunu başlat

      expect(find.text('Yeni Not Yüklendi'), findsOneWidget);
      expect(find.text('Matematik 1 vize notları yüklendi.'), findsOneWidget);
    });

    testWidgets('SnackBar action butonuna tıklandığında onTap callback tetiklenir',
        (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  InAppNotificationSnackBar.show(
                    context,
                    title: 'Bildirim',
                    onTap: () => actionTapped = true,
                  );
                },
                child: const Text('Göster'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Göster'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Görüntüle'), findsOneWidget);
      final actionFinder = find.byType(SnackBarAction);
      expect(actionFinder, findsOneWidget);
      final SnackBarAction action = tester.widget(actionFinder);
      action.onPressed();
      await tester.pump();

      expect(actionTapped, isTrue);
    });
  });

  group('InAppNotificationHandler Tests', () {
    test('extractTitle ve extractBody notification payload önceliklidir', () {
      const message = RemoteMessage(
        notification: RemoteNotification(
          title: 'Payload Başlık',
          body: 'Payload Gövde',
        ),
        data: {
          'title': 'Data Başlık',
          'body': 'Data Gövde',
        },
      );

      expect(InAppNotificationHandler.extractTitle(message), 'Payload Başlık');
      expect(InAppNotificationHandler.extractBody(message), 'Payload Gövde');
    });

    test('extractTitle ve extractBody data payload fallback yapar', () {
      const message = RemoteMessage(
        data: {
          'title': 'Data Başlık',
          'body': 'Data Gövde',
        },
      );

      expect(InAppNotificationHandler.extractTitle(message), 'Data Başlık');
      expect(InAppNotificationHandler.extractBody(message), 'Data Gövde');
    });

    test('extractTitle boş mesajda varsayılan metin döner, uygulama çökmez', () {
      const message = RemoteMessage();

      expect(InAppNotificationHandler.extractTitle(message), 'Yeni Bildirim');
      expect(InAppNotificationHandler.extractBody(message), isNull);
    });

    testWidgets('navigateToHome navigatorKey üzerinden doğru route açar',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          initialRoute: '/',
          routes: {
            '/': (_) => const Scaffold(body: Text('Giriş Ekranı')),
            AppRoutes.home: (_) => const Scaffold(body: Text('Ana Sayfa')),
          },
        ),
      );

      expect(find.text('Giriş Ekranı'), findsOneWidget);

      InAppNotificationHandler.navigateToHome(navigatorKey: navKey);
      await tester.pumpAndSettle();

      expect(find.text('Ana Sayfa'), findsOneWidget);
    });
  });

  group('AppNotificationListener Tests', () {
    testWidgets('Foreground mesaj geldiğinde SnackBar otomatik tetiklenir',
        (tester) async {
      final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: scaffoldKey,
          home: AppNotificationListener(
            child: const Scaffold(
              body: Text('Mevcut Ekran'),
            ),
          ),
        ),
      );

      expect(find.text('Mevcut Ekran'), findsOneWidget);

      // NotificationService üzerinden foreground mesajı simüle et
      NotificationService.instance.handleForegroundMessage(
        const RemoteMessage(
          notification: RemoteNotification(
            title: 'Canlı Bildirim Testi',
            body: 'Uygulama açıkken test bildirimi.',
          ),
        ),
      );

      await tester.pump(); // Animasyon başlangıcı

      expect(find.text('Canlı Bildirim Testi'), findsOneWidget);
      expect(find.text('Uygulama açıkken test bildirimi.'), findsOneWidget);
    });
  });
}

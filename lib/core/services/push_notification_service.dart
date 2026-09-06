import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';

/// Arka planda gelen bildirimleri yakalayan handler (üst düzey fonksiyon olmalıdır).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Arka planda bildirim alındı: ${message.messageId}',
    name: 'PushNotification',
  );
}

/// Firebase Cloud Messaging (Push Notification) servisi.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Bildirim servisini başlatır, izin ister ve cihaz token'ını konsola yazdırır.
  Future<void> initialize() async {
    try {
      // 1. Android 13+ ve iOS için kullanıcıdan bildirim izni iste
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      developer.log(
        'Bildirim İzni Durumu: ${settings.authorizationStatus}',
        name: 'PushNotification',
      );

      // 2. Arka plan mesaj dinleyicisini tanımla
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Cihazın FCM Test Token'ını al ve terminalde belirgin şekilde yazdır
      final token = await _fcm.getToken();
      developer.log(
        '\n======================================================\n'
        '[FCM TEST TOKEN] Firebase Console için Token:\n'
        '${token ?? "Token alınamadı"}\n'
        '======================================================',
        name: 'PushNotification',
      );

      // 4. Genel duyurular için 'all_users' konusuna abone ol
      await _fcm.subscribeToTopic('all_users');

      // 5. Uygulama ön plandayken gelen mesajları dinle
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'Ön planda bildirim geldi: ${message.notification?.title} - ${message.notification?.body}',
          name: 'PushNotification',
        );
      });
    } catch (e) {
      developer.log(
        'Push Notification başlatma hatası: $e',
        name: 'PushNotification',
        level: 1000,
      );
    }
  }
}

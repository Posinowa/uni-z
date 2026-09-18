import 'package:firebase_messaging/firebase_messaging.dart';

/// Arka planda gelen bildirimleri yakalayan handler (üst düzey fonksiyon olmalıdır).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler
}

/// Firebase Cloud Messaging (Push Notification) servisi.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Bildirim servisini başlatır ve izin ister.
  Future<void> initialize() async {
    try {
      // 1. Android 13+ ve iOS için kullanıcıdan bildirim izni iste
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // 2. Arka plan mesaj dinleyicisini tanımla
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Genel duyurular için 'all_users' konusuna abone ol
      await _fcm.subscribeToTopic('all_users');

      // 4. Uygulama ön plandayken gelen mesajları dinle
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Ön planda bildirim işleme
      });
    } catch (_) {
      // Hata durumunda sessizce devam et
    }
  }
}

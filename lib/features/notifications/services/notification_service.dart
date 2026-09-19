import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Arka planda gelen bildirimleri yakalayan handler.
///
/// Bu fonksiyon üst düzey (top-level) olmalıdır;
/// bir sınıf metodu veya anonim fonksiyon olamaz.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Arka plan mesajı alındı — şu an için ek işlem yapılmıyor.
  // İleride local notification gösterimi eklenebilir.
}

/// Firebase Cloud Messaging (FCM) bildirim servisi.
///
/// Singleton pattern ile tek bir instance üzerinden çalışır.
/// Uygulama başlatılırken [initialize] çağrılarak bildirim altyapısı kurulur.
///
/// Örnek kullanım:
/// ```dart
/// await NotificationService.instance.initialize();
/// ```
class NotificationService {
  NotificationService._();

  /// Singleton instance.
  static final NotificationService instance = NotificationService._();

  /// Firebase Messaging instance.
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Foreground'da mesaj alındığında tetiklenen callback.
  ///
  /// [main.dart] içinde set edilerek snackbar gösterimi sağlanır.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Bildirim servisini başlatır.
  ///
  /// Sırasıyla:
  /// 1. Kullanıcıdan bildirim izni ister (Android 13+ ve iOS).
  /// 2. Arka plan mesaj handler'ını tanımlar.
  /// 3. FCM token'ı alır ve debug modda konsola basar.
  /// 4. Foreground mesaj dinleyicisini kurar.
  Future<void> initialize() async {
    // 1. Bildirim izni iste
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint(
        'FCM izin durumu: ${settings.authorizationStatus}',
      );
    }

    // 2. Arka plan mesaj handler'ını tanımla
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // 3. FCM token al
    final token = await getToken();
    if (kDebugMode) {
      debugPrint('FCM Token: $token');
    }

    // 4. Foreground mesaj dinleyicisini kur
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Güncel FCM token'ı döndürür.
  ///
  /// Token alınamazsa `null` döner.
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token alınamadı: $e');
      }
      return null;
    }
  }

  /// Foreground'da gelen mesajları işler.
  ///
  /// Eğer [onForegroundMessage] callback'i set edilmişse onu çağırır.
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        'Foreground mesaj alındı: ${message.notification?.title}',
      );
    }

    // Callback set edildiyse çağır (snackbar gösterimi için)
    onForegroundMessage?.call(message);
  }
}

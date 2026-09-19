import 'dart:async';

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
}

/// Firebase Cloud Messaging (FCM) bildirim servisi.
///
/// Singleton pattern ile tek bir instance üzerinden çalışır.
/// Uygulama başlatılırken [initialize] çağrılarak bildirim altyapısı kurulur.
/// Kullanıcı giriş yaptıktan sonra [saveTokenForUser] çağrılarak token Firestore'a kaydedilir.
///
/// Örnek kullanım:
/// ```dart
/// await NotificationService.instance.initialize();
/// await NotificationService.instance.saveTokenForUser(userId);
/// ```
class NotificationService {
  NotificationService._();

  /// Singleton instance.
  static final NotificationService instance = NotificationService._();

  /// Token yenilendiğinde Firestore'u güncelleyen listener subscription.
  StreamSubscription<String>? _tokenRefreshSub;

  /// FirebaseMessaging instance — lazy erişim ile test ortamında crash önlenir.
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

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
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('FCM izin durumu: ${settings.authorizationStatus}');
    }

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    final token = await getToken();
    if (kDebugMode) {
      debugPrint('FCM Token: $token');
    }

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

  /// Kullanıcının FCM token'ını Firestore'a kaydeder ve token refresh listener'ı başlatır.
  ///
  /// [userId] geçerli bir Firebase Auth UID olmalıdır.
  /// Token Firestore `users/{userId}.fcmTokens` array'ine [ProfileService.addFcmToken] ile eklenir.
  /// `arrayUnion` kullanıldığı için aynı token tekrar eklenmez.
  ///
  /// Ayrıca [FirebaseMessaging.instance.onTokenRefresh] dinlenerek
  /// token yenilendiğinde Firestore otomatik güncellenir.
  Future<void> saveTokenForUser(
    String userId, {
    required Future<void> Function(String userId, String token) saveCallback,
  }) async {
    if (userId.trim().isEmpty) return;

    try {
      // Mevcut token'ı kaydet
      final token = await getToken();
      if (token != null) {
        await saveCallback(userId, token);
      }

      // Eski listener varsa iptal et
      await _tokenRefreshSub?.cancel();

      // Token yenilendiğinde otomatik güncelle
      _tokenRefreshSub = _fcm.onTokenRefresh.listen((newToken) async {
        await saveCallback(userId, newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('saveTokenForUser başarısız: $e');
      }
    }
  }

  /// Token refresh listener'ı iptal eder.
  ///
  /// Kullanıcı çıkış yaptığında çağrılır.
  Future<void> disposeForUser() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  /// Foreground'da gelen mesajları işler.
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('Foreground mesaj alındı: ${message.notification?.title}');
    }
    onForegroundMessage?.call(message);
  }
}

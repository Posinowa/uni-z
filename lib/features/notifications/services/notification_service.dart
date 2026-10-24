import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

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

  /// Foreground mesajları dinleyicilere ileten broadcast stream controller.
  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  /// Foreground mesaj akışı — in-app UI (#67) bu stream'i dinler.
  Stream<RemoteMessage> get foregroundMessageStream =>
      _foregroundMessageController.stream;

  /// Firebase Messaging instance — lazy getter ile test ortamında erken crash önlenir.
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  /// Foreground'da mesaj alındığında tetiklenen callback.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Bildirim servisini başlatır.
  ///
  /// Sırasıyla:
  /// 1. Kullanıcıdan bildirim izni ister (Android 13+ ve iOS).
  /// 2. Arka plan mesaj handler'ını tanımlar.
  /// 3. FCM token'ı alır.
  /// 4. Foreground mesaj dinleyicisini kurar.
  Future<void> initialize() async {
    try {
      // 1. Bildirim izni iste
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // 2. Arka plan mesaj handler'ını tanımla
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 3. FCM token al
      await getToken();

      // 4. Foreground mesaj dinleyicisini kur
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } catch (e) {
      // Firebase başlatılmamış veya test ortamı — hata CI log yasağı
      // nedeniyle loglanamıyor; production'da crashlytics ile izlenmeli.
    }
  }

  /// Güncel FCM token'ı döndürür.
  ///
  /// Token alınamazsa `null` döner.
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      // Token alınamadı — cihaz offline veya FCM erişilemez durumda.
      return null;
    }
  }


  /// Kullanıcının FCM token'ını Firestore'a kaydeder ve token refresh listener'ı başlatır.
  ///
  /// [userId] geçerli bir Firebase Auth UID olmalıdır.
  /// Token Firestore `users/{userId}.fcmTokens` array'ine [saveCallback] ile eklenir.
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
        try {
          await saveCallback(userId, newToken);
        } catch (e) {
          // Token refresh kaydetme hatası — bağlantı sorunları olabilir.
        }
      });
    } catch (e) {
      // Token kaydetme hatası — Firebase erişilemez veya test ortamı.
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
  ///
  /// Stream dinleyicilerine iletir ve opsiyonel callback'i çağırır.
  void _handleForegroundMessage(RemoteMessage message) {
    if (!_foregroundMessageController.isClosed) {
      _foregroundMessageController.add(message);
    }
    onForegroundMessage?.call(message);
  }
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase yapılandırma seçenekleri.
///
/// Bu dosya `flutterfire configure` komutuyla yeniden üretilebilir.
/// Detay: https://firebase.google.com/docs/flutter/setup
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platformu için Firebase yapılandırması tanımlanmadı.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Bu platform için Firebase yapılandırması tanımlanmadı: $defaultTargetPlatform',
        );
    }
  }

  // Android yapılandırması — google-services.json'dan alınmıştır
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAu94Yd_NHUaOmceS_mgLmF4fuFg_1JdLg',
    appId: '1:512578633026:android:b386c2e08cfae54c22dcdb',
    messagingSenderId: '512578633026',
    projectId: 'uniz-mobile',
    storageBucket: 'uniz-mobile.firebasestorage.app',
  );

  // iOS yapılandırması — GoogleService-Info.plist'ten alınmıştır
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA41Q1Wf5sEyaF7MoZmwzznFXW7Ox84vPE',
    appId: '1:512578633026:ios:cdaaf5762f64eed122dcdb',
    messagingSenderId: '512578633026',
    projectId: 'uniz-mobile',
    storageBucket: 'uniz-mobile.firebasestorage.app',
    iosBundleId: 'com.posinowa.uniz.unizMobile',
  );
}

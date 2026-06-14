import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase yapılandırma seçenekleri.
///
/// Bu dosya çevre değişkenlerini `.env` dosyasından okur.
/// Gerçek API anahtarları **asla** bu dosyada tutulmaz.
///
/// Kurulum:
///   1. `.env.example` dosyasını `.env` olarak kopyalayın.
///   2. Firebase konsolundan aldığınız değerleri doldurun.
///   3. `.env` dosyasını asla commit etmeyin.
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

  // Android yapılandırması — .env dosyasından okunur
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY']!,
    appId: dotenv.env['FIREBASE_ANDROID_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
  );

  // iOS yapılandırması — .env dosyasından okunur
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY']!,
    appId: dotenv.env['FIREBASE_IOS_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
    iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID']!,
  );
}

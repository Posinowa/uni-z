import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Uni'z uygulamasındaki hata kodlarını ve istisnaları
/// kullanıcı dostu Türkçe mesajlara dönüştüren merkezi hata mapper sınıfı.
class AppErrorMapper {
  // Private constructor — sınıf sadece static metotlar barındırır.
  AppErrorMapper._();

  /// Kullanıcıya gösterilecek varsayılan genel hata mesajı.
  static const String defaultErrorMessage =
      'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  /// Ham exception mesajlarındaki `[servis/kod]` kalıbını ayıklayan regex.
  static final RegExp _bracketCodeRegex =
      RegExp(r'\[(?:[a-zA-Z0-9_]+)\/([a-zA-Z0-9_-]+)\]');

  /// Herhangi bir nesneyi/hatayı analiz edip kullanıcı dostu Türkçe mesaj döndürür.
  ///
  /// - [error] bir [FirebaseAuthException] ise auth hata koduna göre mesaj üretir.
  /// - [error] bir [FirebaseException] ise genel Firebase hata koduna bakar.
  /// - [error] bir [PlatformException] ise platform hata kodunu çözümler.
  /// - [error] bir [String] ise hata kodunu, regex desenini veya metni çözümler.
  /// - Diğer tüm durumlarda veya null olduğunda [defaultErrorMessage] döndürür.
  static String map(Object? error) {
    if (error == null) {
      return defaultErrorMessage;
    }

    if (error is FirebaseAuthException) {
      return fromFirebaseAuthException(error);
    }

    if (error is FirebaseException) {
      return fromFirebaseErrorCode(error.code);
    }

    if (error is PlatformException) {
      return fromFirebaseErrorCode(error.code);
    }

    if (error is String) {
      return fromString(error);
    }

    return defaultErrorMessage;
  }

  /// [FirebaseAuthException] nesnesini kullanıcı dostu Türkçe mesaja çevirir.
  static String fromFirebaseAuthException(FirebaseAuthException exception) {
    return fromFirebaseErrorCode(exception.code);
  }

  /// Firebase Auth, Firestore ve genel platform hata kodlarını
  /// kullanıcı dostu Türkçe mesaja çevirir.
  ///
  /// Başında `auth/`, `firebase_auth/`, `cloud_firestore/` gibi önekler varsa
  /// temizler ve alt tireleri (`_`) tireye (`-`) çevirerek normalize eder.
  static String fromFirebaseErrorCode(String? code) {
    if (code == null) {
      return defaultErrorMessage;
    }

    var normalizedCode = code.trim().toLowerCase();
    if (normalizedCode.isEmpty) {
      return defaultErrorMessage;
    }

    // Başındaki servis öneklerini ayıkla (örn: auth/user-not-found -> user-not-found)
    if (normalizedCode.contains('/')) {
      normalizedCode = normalizedCode.split('/').last;
    }

    // Alt tireleri tireye çevir (örn: user_not_found -> user-not-found)
    normalizedCode = normalizedCode.replaceAll('_', '-');

    switch (normalizedCode) {
      // ── Kimlik Doğrulama & Giriş Hataları ──
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Girdiğiniz şifre hatalı.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-mismatch':
        return 'Verilen kimlik bilgileri mevcut kullanıcıyla eşleşmiyor.';
      case 'credential-already-in-use':
        return 'Bu kimlik bilgisi zaten başka bir hesapla ilişkili.';
      case 'popup-closed-by-user':
      case 'web-context-cancelled':
        return 'Giriş işlemi iptal edildi.';
      case 'invalid-phone-number':
        return 'Geçersiz telefon numarası.';

      // ── Kayıt Hataları ──
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu anda etkin değil.';

      // ── Güvenlik & Oturum Hataları ──
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresiyle ilişkili farklı bir giriş yöntemi mevcut.';
      case 'session-cookie-expired':
      case 'user-token-expired':
        return 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';

      // ── Ağ & Bağlantı Hataları ──
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';

      // ── Kod & Doğrulama Hataları ──
      case 'invalid-verification-code':
        return 'Geçersiz doğrulama kodu.';
      case 'invalid-verification-id':
        return 'Geçersiz doğrulama kimliği.';
      case 'expired-action-code':
        return 'İşlem kodunun süresi dolmuş. Lütfen tekrar deneyin.';
      case 'invalid-action-code':
        return 'Geçersiz işlem kodu.';

      // ── Firestore & Genel Servis Hata Kodları ──
      case 'permission-denied':
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 'unavailable':
        return 'Hizmete şu anda ulaşılamıyor. Lütfen daha sonra tekrar deneyin.';
      case 'not-found':
        return 'İstenen kayıt bulunamadı.';
      case 'already-exists':
        return 'Bu kayıt zaten mevcut.';
      case 'deadline-exceeded':
        return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';

      // ── Form & Kanal Hataları ──
      case 'channel-error':
        return 'Lütfen gerekli alanları doldurun.';

      default:
        return defaultErrorMessage;
    }
  }

  /// Form alanları veya genel hata anahtarlarını kullanıcı dostu mesaja çevirir.
  static String fromFormError(String? errorKey) {
    if (errorKey == null) {
      return defaultErrorMessage;
    }

    final trimmed = errorKey.trim();
    if (trimmed.isEmpty) {
      return defaultErrorMessage;
    }

    switch (trimmed.toLowerCase()) {
      case 'required_field':
      case 'field_required':
      case 'required':
        return 'Lütfen bu alanı doldurun.';
      case 'invalid_email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'password_too_short':
        return 'Şifre en az 6 karakter olmalı.';
      case 'passwords_do_not_match':
        return 'Şifreler eşleşmiyor.';
      default:
        return trimmed;
    }
  }

  /// String tipindeki hataları kullanıcı dostu mesaja çevirir.
  ///
  /// - `[firebase_auth/kod]` veya `[cloud_firestore/kod]` deseni içeriyorsa kodu ayıklar.
  /// - Doğrudan bir hata kodu veya form anahtarıysa Türkçe karşılığını döndürür.
  /// - Teknik exception/hata izi içeriyorsa ve bilinen bir koda çözülemiyorsa
  ///   teknik İngilizceyi kullanıcıya sızdırmamak adına [defaultErrorMessage] döner.
  static String fromString(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return defaultErrorMessage;
    }

    // 1. [firebase_auth/user-not-found] gibi tag desenini ara
    final match = _bracketCodeRegex.firstMatch(trimmed);
    if (match != null) {
      final extractedCode = match.group(1);
      final mapped = fromFirebaseErrorCode(extractedCode);
      if (mapped != defaultErrorMessage) {
        return mapped;
      }
    }

    // 2. Doğrudan bir Firebase/Firestore hata kodu mu kontrol et
    final directFirebase = fromFirebaseErrorCode(trimmed);
    if (directFirebase != defaultErrorMessage) {
      return directFirebase;
    }

    // 3. Bilinen form hata anahtarı mı kontrol et
    final formMessage = fromFormError(trimmed);
    if (formMessage != trimmed && formMessage != defaultErrorMessage) {
      return formMessage;
    }

    // 4. Teknik hata formatı kontrolü (Exception:, PlatformException, Error:, SocketException vb.)
    if (_isTechnicalException(trimmed)) {
      return defaultErrorMessage;
    }

    return trimmed;
  }

  /// Metnin teknik bir istisna veya hata izi içerip içermediğini kontrol eder.
  static bool _isTechnicalException(String text) {
    final lower = text.toLowerCase();
    return lower.contains('exception:') ||
        lower.contains('platformexception') ||
        lower.contains('socketexception') ||
        lower.contains('error:') ||
        lower.contains('formatexception') ||
        lower.contains('typeerror') ||
        lower.contains('assertionerror');
  }
}

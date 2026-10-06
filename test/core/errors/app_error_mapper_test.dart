import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/core/errors/app_error_mapper.dart';
import 'package:uniz_mobile/core/helpers/app_error_mapper.dart' as helper_import;

void main() {
  group('AppErrorMapper', () {
    const defaultMsg = 'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

    test('varsayılan hata mesajı doğru tanımlanmalı', () {
      expect(AppErrorMapper.defaultErrorMessage, defaultMsg);
    });

    group('fromFirebaseErrorCode', () {
      test('null, boş veya boşluklu kodlarda varsayılan hata mesajı dönmeli', () {
        expect(AppErrorMapper.fromFirebaseErrorCode(null), defaultMsg);
        expect(AppErrorMapper.fromFirebaseErrorCode(''), defaultMsg);
        expect(AppErrorMapper.fromFirebaseErrorCode('   '), defaultMsg);
      });

      test('bilinmeyen hata kodunda varsayılan hata mesajı dönmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('unknown-custom-error'),
          defaultMsg,
        );
      });

      test('kimlik doğrulama ve giriş hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('user-not-found'),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('wrong-password'),
          'Girdiğiniz şifre hatalı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('invalid-credential'),
          'E-posta veya şifre hatalı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('user-disabled'),
          'Bu hesap devre dışı bırakılmış.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('invalid-email'),
          'Geçersiz e-posta adresi.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('user-mismatch'),
          'Verilen kimlik bilgileri mevcut kullanıcıyla eşleşmiyor.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('credential-already-in-use'),
          'Bu kimlik bilgisi zaten başka bir hesapla ilişkili.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('popup-closed-by-user'),
          'Giriş işlemi iptal edildi.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('web-context-cancelled'),
          'Giriş işlemi iptal edildi.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('invalid-phone-number'),
          'Geçersiz telefon numarası.',
        );
      });

      test('kayıt hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('email-already-in-use'),
          'Bu e-posta adresi zaten kullanımda.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('weak-password'),
          'Şifre çok zayıf. En az 6 karakter olmalı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('operation-not-allowed'),
          'Bu giriş yöntemi şu anda etkin değil.',
        );
      });

      test('güvenlik ve oturum hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('too-many-requests'),
          'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('requires-recent-login'),
          'Bu işlem için yeniden giriş yapmanız gerekiyor.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode(
            'account-exists-with-different-credential',
          ),
          'Bu e-posta adresiyle ilişkili farklı bir giriş yöntemi mevcut.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('session-cookie-expired'),
          'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('user-token-expired'),
          'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
      });

      test('ağ hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('network-request-failed'),
          'İnternet bağlantınızı kontrol edin.',
        );
      });

      test('doğrulama ve işlem kodu hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('invalid-verification-code'),
          'Geçersiz doğrulama kodu.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('invalid-verification-id'),
          'Geçersiz doğrulama kimliği.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('expired-action-code'),
          'İşlem kodunun süresi dolmuş. Lütfen tekrar deneyin.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('invalid-action-code'),
          'Geçersiz işlem kodu.',
        );
      });

      test('Firestore ve genel servis hata kodlarını doğru çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('permission-denied'),
          'Bu işlem için yetkiniz bulunmuyor.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('unavailable'),
          'Hizmete şu anda ulaşılamıyor. Lütfen daha sonra tekrar deneyin.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('not-found'),
          'İstenen kayıt bulunamadı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('already-exists'),
          'Bu kayıt zaten mevcut.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('deadline-exceeded'),
          'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.',
        );
      });

      test('kanal ve form hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('channel-error'),
          'Lütfen gerekli alanları doldurun.',
        );
      });

      test('auth/ ve firebase_auth/ gibi önekleri başarıyla ayıklamalı', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('auth/user-not-found'),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('firebase_auth/invalid-credential'),
          'E-posta veya şifre hatalı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('cloud_firestore/permission-denied'),
          'Bu işlem için yetkiniz bulunmuyor.',
        );
      });

      test('alt tire (_) içeren kodları tireye (-) çevirerek eşlemeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('user_not_found'),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('auth/wrong_password'),
          'Girdiğiniz şifre hatalı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('credential_already_in_use'),
          'Bu kimlik bilgisi zaten başka bir hesapla ilişkili.',
        );
      });

      test('büyük harf ve boşluk içeren kodları normalize ederek işlemeli', () {
        expect(
          AppErrorMapper.fromFirebaseErrorCode('  AUTH/USER-NOT-FOUND  '),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromFirebaseErrorCode('Wrong_Password'),
          'Girdiğiniz şifre hatalı.',
        );
      });
    });

    group('fromFirebaseAuthException', () {
      test('FirebaseAuthException nesnesini doğru mesaja çevirmeli', () {
        final exception = FirebaseAuthException(
          code: 'wrong-password',
          message: 'The password is invalid or the user does not have a password.',
        );
        expect(
          AppErrorMapper.fromFirebaseAuthException(exception),
          'Girdiğiniz şifre hatalı.',
        );
      });

      test('önekli kod taşıyan FirebaseAuthException nesnesini doğru mesaja çevirmeli', () {
        final exception = FirebaseAuthException(code: 'auth/user-not-found');
        expect(
          AppErrorMapper.fromFirebaseAuthException(exception),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
      });

      test('bilinmeyen kodlu FirebaseAuthException varsayılan mesaj dönmeli', () {
        final exception = FirebaseAuthException(code: 'unknown-code');
        expect(
          AppErrorMapper.fromFirebaseAuthException(exception),
          defaultMsg,
        );
      });
    });

    group('fromFormError', () {
      test('null veya boş anahtarlarda varsayılan hata mesajı dönmeli', () {
        expect(AppErrorMapper.fromFormError(null), defaultMsg);
        expect(AppErrorMapper.fromFormError(''), defaultMsg);
        expect(AppErrorMapper.fromFormError('   '), defaultMsg);
      });

      test('bilinen form hatalarını kullanıcı dostu mesaja çevirmeli', () {
        expect(
          AppErrorMapper.fromFormError('required_field'),
          'Lütfen bu alanı doldurun.',
        );
        expect(
          AppErrorMapper.fromFormError('field_required'),
          'Lütfen bu alanı doldurun.',
        );
        expect(
          AppErrorMapper.fromFormError('required'),
          'Lütfen bu alanı doldurun.',
        );
        expect(
          AppErrorMapper.fromFormError('invalid_email'),
          'Geçerli bir e-posta adresi girin.',
        );
        expect(
          AppErrorMapper.fromFormError('password_too_short'),
          'Şifre en az 6 karakter olmalı.',
        );
        expect(
          AppErrorMapper.fromFormError('passwords_do_not_match'),
          'Şifreler eşleşmiyor.',
        );
      });

      test('bilinmeyen anahtar verildiğinde kendisini dönmeli', () {
        expect(
          AppErrorMapper.fromFormError('Özel bir form hata uyarısı'),
          'Özel bir form hata uyarısı',
        );
      });
    });

    group('fromString', () {
      test('boş veya boşluk string için varsayılan mesaj dönmeli', () {
        expect(AppErrorMapper.fromString(''), defaultMsg);
        expect(AppErrorMapper.fromString('   '), defaultMsg);
      });

      test('ham exception string içindeki [servis/kod] desenini başarıyla çözmeli', () {
        expect(
          AppErrorMapper.fromString(
            '[firebase_auth/user-not-found] There is no user record corresponding to this identifier.',
          ),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromString(
            '[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired.',
          ),
          'E-posta veya şifre hatalı.',
        );
        expect(
          AppErrorMapper.fromString(
            '[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.',
          ),
          'Bu işlem için yetkiniz bulunmuyor.',
        );
      });

      test('Firebase hata kodu string olarak verildiğinde eşlemeli', () {
        expect(
          AppErrorMapper.fromString('user-not-found'),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromString('auth/user-not-found'),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
        expect(
          AppErrorMapper.fromString('firebase_auth/invalid-credential'),
          'E-posta veya şifre hatalı.',
        );
      });

      test('form hata anahtarı string olarak verildiğinde eşlemeli', () {
        expect(
          AppErrorMapper.fromString('password_too_short'),
          'Şifre en az 6 karakter olmalı.',
        );
        expect(
          AppErrorMapper.fromString('required_field'),
          'Lütfen bu alanı doldurun.',
        );
      });

      test('standart güvenli kullanıcı metni verildiğinde metni korumalı', () {
        expect(
          AppErrorMapper.fromString('Kullanıcı adı en az 3 karakter olmalı'),
          'Kullanıcı adı en az 3 karakter olmalı',
        );
      });

      test('çözümlenemeyen teknik exception ve error stringlerinde defaultErrorMessage dönmeli', () {
        expect(
          AppErrorMapper.fromString(
            'Exception: An internal server error occurred',
          ),
          defaultMsg,
        );
        expect(
          AppErrorMapper.fromString(
            'PlatformException(ERROR_UNKNOWN, An unknown native error, null, null)',
          ),
          defaultMsg,
        );
        expect(
          AppErrorMapper.fromString(
            'SocketException: OS Error: Connection refused, errno = 61',
          ),
          defaultMsg,
        );
        expect(
          AppErrorMapper.fromString(
            'Error: RangeError (index): Invalid value: Valid value range is empty: 0',
          ),
          defaultMsg,
        );
        expect(
          AppErrorMapper.fromString(
            'FormatException: Unexpected character at line 1',
          ),
          defaultMsg,
        );
      });
    });

    group('map (Genel Mapping & PlatformException)', () {
      test('null verildiğinde varsayılan mesaj dönmeli', () {
        expect(AppErrorMapper.map(null), defaultMsg);
      });

      test('FirebaseAuthException verildiğinde doğru eşlemeli', () {
        final exception = FirebaseAuthException(code: 'user-not-found');
        expect(
          AppErrorMapper.map(exception),
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        );
      });

      test('FirebaseException verildiğinde code alanını eşlemeli', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'network-request-failed',
        );
        expect(
          AppErrorMapper.map(exception),
          'İnternet bağlantınızı kontrol edin.',
        );
      });

      test('PlatformException bilinen kod taşıdığında doğru eşlemeli', () {
        final exception = PlatformException(
          code: 'network-request-failed',
          message: 'The network connection was lost.',
        );
        expect(
          AppErrorMapper.map(exception),
          'İnternet bağlantınızı kontrol edin.',
        );
      });

      test('PlatformException bilinmeyen kod taşıdığında varsayılan mesaja düşmeli', () {
        final exception = PlatformException(
          code: 'SOME_NATIVE_UNKNOWN_CODE',
          message: 'Unhandled native exception',
        );
        expect(AppErrorMapper.map(exception), defaultMsg);
      });

      test('SocketException nesnesi verildiğinde varsayılan mesaja düşmeli', () {
        final exception = const SocketException('Failed host lookup');
        expect(AppErrorMapper.map(exception), defaultMsg);
      });

      test('String verildiğinde fromString üzerinden işlemeli', () {
        expect(
          AppErrorMapper.map('too-many-requests'),
          'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.',
        );
        expect(
          AppErrorMapper.map('[firebase_auth/wrong-password] Wrong password'),
          'Girdiğiniz şifre hatalı.',
        );
      });

      test('Bilinmeyen nesne veya genel Exception verildiğinde varsayılan mesaj dönmeli', () {
        expect(AppErrorMapper.map(Exception('Server error 500')), defaultMsg);
        expect(AppErrorMapper.map(12345), defaultMsg);
      });
    });

    group('Helper Export Uyumluluğu', () {
      test('lib/core/helpers/ üzerinden de aynı sınıf kullanılabilir olmalı', () {
        expect(
          helper_import.AppErrorMapper.defaultErrorMessage,
          AppErrorMapper.defaultErrorMessage,
        );
        expect(
          helper_import.AppErrorMapper.fromFirebaseErrorCode('auth/wrong_password'),
          'Girdiğiniz şifre hatalı.',
        );
        expect(
          helper_import.AppErrorMapper.fromFirebaseErrorCode('cloud_firestore/permission_denied'),
          'Bu işlem için yetkiniz bulunmuyor.',
        );
      });
    });
  });
}

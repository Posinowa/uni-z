import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Auth durumunu yöneten Provider sınıfı.
///
/// Firebase Auth işlemlerini [AuthService] üzerinden gerçekleştirir.
/// UI katmanı Firebase'e direkt erişmez — tüm işlemler bu provider
/// üzerinden yapılır.
///
/// Yönetilen durumlar:
/// - [currentUser]: Giriş yapmış kullanıcı (null ise giriş yapılmamış).
/// - [isLoading]: İşlem devam ederken true olur.
/// - [errorMessage]: Hata mesajı (null ise hata yok).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  late final StreamSubscription<User?> _authSubscription;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Firebase Auth state değişikliklerini dinle
    _authSubscription = _authService.authStateChanges().listen(_onAuthChanged);
    _currentUser = _authService.currentUser;
  }

  // ── Getter'lar ──

  /// Şu an giriş yapmış kullanıcı. Giriş yapılmamışsa null.
  User? get currentUser => _currentUser;

  /// Bir auth işlemi devam ediyorsa true.
  bool get isLoading => _isLoading;

  /// Son işlemde oluşan hata mesajı. Hata yoksa null.
  String? get errorMessage => _errorMessage;

  /// Kullanıcının giriş yapıp yapmadığını döner.
  bool get isLoggedIn => _currentUser != null;

  // ── Auth İşlemleri ──

  /// Email ve şifre ile giriş yapar.
  ///
  /// Başarılıysa [currentUser] güncellenir.
  /// Hata olursa [errorMessage] set edilir.
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      _setLoading(false);
    }
  }

  /// Email ve şifre ile yeni hesap oluşturur.
  ///
  /// Kayıt başarılı olduktan sonra Firebase Auth profilinde
  /// [fullName] ile displayName güncellenir.
  ///
  /// Başarılıysa [currentUser] güncellenir.
  /// Hata olursa [errorMessage] set edilir.
  Future<void> register(
    String fullName,
    String email,
    String password,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.registerWithEmailAndPassword(email, password);

      // Kayıt başarılı — displayName güncelle
      await _authService.currentUser?.updateDisplayName(fullName);
      await _authService.currentUser?.reload();
      _currentUser = _authService.currentUser;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      _setLoading(false);
    }
  }

  /// Şifre sıfırlama e-postası gönderir.
  ///
  /// Hata olursa [errorMessage] set edilir.
  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı oturumunu kapatır.
  ///
  /// Hata olursa [errorMessage] set edilir.
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Çıkış yapılırken bir hata oluştu.');
    } finally {
      _setLoading(false);
    }
  }

  /// Hata mesajını temizler.
  ///
  /// UI'dan hata gösterildikten sonra çağrılabilir.
  void clearError() {
    _clearError();
  }

  // ── Private Yardımcılar ──

  /// Auth state değişikliklerinde çağrılır.
  void _onAuthChanged(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Firebase Auth hata kodlarını kullanıcı dostu mesajlara çevirir.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Girdiğiniz şifre hatalı.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

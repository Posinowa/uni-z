import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth işlemlerini yöneten servis sınıfı.
///
/// Bu sınıf, Firebase Auth instance'ını tek yerden kullanır.
/// Hatalar try/catch ile üst katmana aktarılabilir.
/// UI kodu içermez.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Şu an giriş yapmış kullanıcıyı döner.
  /// Giriş yapılmamışsa null döner.
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı oturum durumunu dinleyen stream.
  /// Giriş/çıkış değişikliklerinde yeni değer yayınlar.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Email ve şifre ile giriş yapar.
  ///
  /// Başarılıysa [UserCredential] döner.
  /// Hata olursa [FirebaseAuthException] fırlatır.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Email ve şifre ile yeni hesap oluşturur.
  ///
  /// Başarılıysa [UserCredential] döner.
  /// Hata olursa [FirebaseAuthException] fırlatır.
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Şifre sıfırlama e-postası gönderir.
  ///
  /// Hata olursa [FirebaseAuthException] fırlatır.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Kullanıcı oturumunu kapatır.
  ///
  /// Hata olursa [FirebaseAuthException] fırlatır.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

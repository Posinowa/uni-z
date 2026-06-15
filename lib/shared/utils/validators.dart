class Validators {
  /// Ad soyad validation. Boş olamaz.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad soyad gerekli';
    }
    return null;
  }

  /// E-posta validation. Boş olamaz ve geçerli formatta olmalı.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi gerekli';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  /// Şifre validation. Boş olamaz ve en az 6 karakter olmalı.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  /// Şifre tekrar validation. Boş olamaz ve şifreyle eşleşmeli.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrar gerekli';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }
}

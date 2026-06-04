/// Uygulama içindeki tüm route isimlerini tek yerden yönetir.
///
/// Yeni bir ekran eklendiğinde buraya route sabiti eklenmeli
/// ve [AppRouter] içinde ilgili case tanımlanmalıdır.
class AppRoutes {
  AppRoutes._(); // Instance oluşturulmasını engeller.

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String profileCompletion = '/profile-completion';
  static const String home = '/home';
}

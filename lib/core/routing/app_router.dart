import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import 'app_routes.dart';

/// Uygulamanın route yapılandırması.
///
/// [MaterialApp.onGenerateRoute] ile kullanılır.
/// Tanımsız route'lar için fallback ekranı döner.
///
/// Kullanım:
/// ```dart
/// MaterialApp(
///   initialRoute: AppRoutes.splash,
///   onGenerateRoute: AppRouter.onGenerateRoute,
/// )
/// ```
class AppRouter {
  AppRouter._(); // Instance oluşturulmasını engeller.

  /// Route ayarlarına göre doğru ekranı döndürür.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          settings,
          const SplashScreen(),
        );

      case AppRoutes.login:
        return _buildRoute(
          settings,
          const LoginScreen(),
        );

      case AppRoutes.register:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Register'),
        );

      case AppRoutes.forgotPassword:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Forgot Password'),
        );

      case AppRoutes.profileCompletion:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Profile Completion'),
        );

      case AppRoutes.home:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Home'),
        );

      default:
        return _buildRoute(
          settings,
          _NotFoundScreen(routeName: settings.name),
        );
    }
  }

  /// Standart [MaterialPageRoute] oluşturur.
  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder ekranlar — gerçek ekranlar geliştirilene kadar kullanılır.
// ─────────────────────────────────────────────────────────────────────────────

/// Henüz geliştirilmemiş ekranlar için geçici placeholder.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// Tanımsız route'lar için 404 fallback ekranı.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 — Sayfa Bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${routeName ?? "bilinmiyor"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

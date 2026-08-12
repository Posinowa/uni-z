import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// Açılış (Splash) ekranı.
///
/// Uygulama açıldığında kullanıcının oturum durumunu [AuthProvider] üzerinden
/// kontrol eder:
/// - Oturum açmamışsa -> [AppRoutes.login]
/// - Oturum açmışsa -> [AppRoutes.home] (geçici olarak)
///
/// Profil tamamlama ve ek kontroller ilerideki issue'larda eklenecektir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  /// Kullanıcının auth durumunu kontrol eder ve ilgili ekrana yönlendirir.
  void _checkAuthAndNavigate() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ──
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Uygulama İsmi ──
            Text(
              "Uni'z",
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primaryIndigo,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Yükleniyor Göstergesi ──
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

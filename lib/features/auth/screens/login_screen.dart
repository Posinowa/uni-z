import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/profile/services/profile_service.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/text_action_button.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

/// Kullanıcı giriş ekranı.
///
/// E-posta ve şifre ile giriş yapılmasını sağlar.
/// Şifremi unuttum ve kayıt ol yönlendirme linkleri içerir.
///
/// Login işlemi [AuthProvider] üzerinden yapılır — UI direkt Firebase'e erişmez.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    this.profileService,
    super.key,
  });

  final ProfileService? profileService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  ProfileService get _profileService => widget.profileService ?? ProfileService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Giriş yap butonuna basıldığında çalışır.
  ///
  /// Başarılı giriş sonrası Firestore profil kontrol edilir:
  /// - Profil varsa -> /home
  /// - Profil yoksa -> /profile-completion
  Future<void> _onLoginPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();

    await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Widget hâlâ ekrandaysa sonucu kontrol et
    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      // Hata varsa snackbar göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
      authProvider.clearError();
      return;
    }

    if (!authProvider.isLoggedIn) return;

    // Başarılı giriş — Firestore profili kontrol et
    try {
      final uid = authProvider.currentUser!.uid;
      final profile = await _profileService.getUserProfile(uid);

      if (!mounted) return;

      if (profile == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.profileCompletion,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil bilgisi alınamadı. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Şifremi unuttum sayfasına yönlendirir.
  void _onForgotPasswordPressed() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  /// Kayıt ol sayfasına yönlendirir.
  void _onRegisterPressed() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'ın isLoading state'ini dinle
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo / Marka Alanı ──
                    _buildLogo(),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Başlık ──
                    Text(
                      'Giriş Yap',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Üniversite hayatın tek yerde.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── E-posta Input ──
                    AppTextField(
                      label: 'E-posta',
                      hint: 'ornek@mail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Şifre Input ──
                    AppPasswordField(
                      label: 'Şifre',
                      hint: 'Şifrenizi girin',
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Şifremi Unuttum ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextActionButton(
                        text: 'Şifremi Unuttum',
                        onPressed: _onForgotPasswordPressed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Giriş Yap Butonu ──
                    PrimaryButton(
                      text: 'Giriş Yap',
                      onPressed: isLoading ? null : _onLoginPressed,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Kayıt Ol Yönlendirme ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabın yok mu?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextActionButton(
                          text: 'Kayıt Ol',
                          onPressed: _onRegisterPressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Uni'z logo placeholder'ını oluşturur.
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "Uni'z",
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primaryIndigo,
          ),
        ),
      ],
    );
  }
}

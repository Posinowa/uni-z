import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/text_action_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

/// Şifre sıfırlama ekranı.
///
/// Kullanıcı e-posta adresini girerek şifre sıfırlama
/// bağlantısı talep edebilir. Login ekranına dönüş linki içerir.
///
/// Şifre sıfırlama işlemi [AuthProvider] üzerinden gerçekleştirilir.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Şifre sıfırlama bağlantısı gönder butonuna basıldığında çalışır.
  Future<void> _onResetPasswordPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();

    await authProvider.sendPasswordReset(_emailController.text.trim());

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
      authProvider.clearError();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Login ekranına geri döner.
  void _onBackToLoginPressed() {
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
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
                      'Şifremi Unuttum',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Açıklama Metni ──
                    Text(
                      'E-posta adresinizi girin, size şifre sıfırlama '
                      'bağlantısı gönderelim.',
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
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Şifre Sıfırlama Butonu ──
                    PrimaryButton(
                      text: 'Sıfırlama Bağlantısı Gönder',
                      onPressed: _onResetPasswordPressed,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Giriş Yap'a Dön Linki ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Şifreni hatırladın mı?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextActionButton(
                          text: 'Giriş Yap',
                          onPressed: _onBackToLoginPressed,
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

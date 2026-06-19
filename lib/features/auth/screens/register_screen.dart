import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/text_action_button.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';

/// Kullanıcı kayıt ekranı.
///
/// Ad soyad, e-posta, şifre ve şifre tekrar alanları içerir.
/// Kayıt ol butonu, giriş yap yönlendirme linki ve
/// kullanım şartları kısa metni bulunur.
///
/// Firebase kayıt bu ekranda yapılmaz — sadece UI katmanıdır.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Kayıt ol butonuna basıldığında çalışır.
  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Firebase Auth entegrasyonu yapılacak.
    }
  }

  /// Giriş yap sayfasına yönlendirir.
  void _onLoginPressed() {
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
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
                      'Kayıt Ol',
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

                    // ── Ad Soyad Input ──
                    AppTextField(
                      label: 'Ad Soyad',
                      hint: 'Adınızı ve soyadınızı girin',
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: AppSpacing.lg),

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
                      hint: 'En az 6 karakter',
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Şifre Tekrar Input ──
                    AppPasswordField(
                      label: 'Şifre Tekrar',
                      hint: 'Şifrenizi tekrar girin',
                      controller: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Kullanım Şartları Metni ──
                    Text(
                      'Kayıt olarak Kullanım Şartları\'nı ve '
                      'Gizlilik Politikası\'nı kabul etmiş olursunuz.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Kayıt Ol Butonu ──
                    PrimaryButton(
                      text: 'Kayıt Ol',
                      onPressed: _onRegisterPressed,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Giriş Yap Yönlendirme ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zaten hesabın var mı?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextActionButton(
                          text: 'Giriş Yap',
                          onPressed: _onLoginPressed,
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

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import 'base_button.dart';

/// Ana aksiyon butonu — dolu arka planlı, beyaz metin.
///
/// Kayıt ol, giriş yap, gönder gibi birincil aksiyonlar için kullanılır.
///
/// Örnek:
/// ```dart
/// PrimaryButton(
///   text: 'Giriş Yap',
///   onPressed: () => _login(),
///   isLoading: _isSubmitting,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    super.key,
  });

  /// Buton üzerinde gösterilecek metin.
  final String text;

  /// Butona tıklandığında çalışacak fonksiyon.
  final VoidCallback? onPressed;

  /// Opsiyonel ikon — metnin solunda gösterilir.
  final IconData? icon;

  /// `true` ise buton tıklanamaz olur ve spinner gösterilir.
  final bool isLoading;

  /// `true` ise buton tıklanamaz (disabled) olur.
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      loadingIndicatorColor: Colors.white,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primaryIndigo.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }
}

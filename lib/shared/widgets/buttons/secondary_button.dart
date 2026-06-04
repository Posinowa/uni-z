import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import 'base_button.dart';

/// İkincil aksiyon butonu — cyan arka planlı, beyaz metin.
///
/// Primary butonun yanında ikincil bir aksiyon gerektiğinde kullanılır.
///
/// Örnek:
/// ```dart
/// SecondaryButton(
///   text: 'Devam Et',
///   onPressed: () => _continue(),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
        backgroundColor: AppColors.secondaryCyan,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            AppColors.secondaryCyan.withValues(alpha: 0.5),
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

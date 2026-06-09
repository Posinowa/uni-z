import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import 'base_button.dart';

/// Kenarlıklı buton — şeffaf arka plan, indigo kenarlık ve metin.
///
/// İptal, geri dön gibi daha az vurgulu aksiyonlar için kullanılır.
///
/// Örnek:
/// ```dart
/// OutlineButton(
///   text: 'İptal',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class OutlineButton extends StatelessWidget {
  const OutlineButton({
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
      loadingIndicatorColor: AppColors.primaryIndigo,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryIndigo,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor:
            AppColors.primaryIndigo.withValues(alpha: 0.5),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: (isLoading || isDisabled)
                ? AppColors.border
                : AppColors.primaryIndigo,
          ),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }
}

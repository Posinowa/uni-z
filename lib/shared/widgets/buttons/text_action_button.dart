import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Metin tabanlı aksiyon butonu — arka plan ve kenarlık yok.
///
/// "Şifremi unuttum", "Tümünü gör" gibi satır içi aksiyonlar için kullanılır.
///
/// Örnek:
/// ```dart
/// TextActionButton(
///   text: 'Şifremi Unuttum',
///   onPressed: () => _forgotPassword(),
/// )
/// ```
class TextActionButton extends StatelessWidget {
  const TextActionButton({
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
    // Loading veya disabled durumda onPressed null olur → buton tıklanamaz.
    final VoidCallback? effectiveOnPressed =
        (isLoading || isDisabled) ? null : onPressed;

    return TextButton(
      onPressed: effectiveOnPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryIndigo,
        disabledForegroundColor:
            AppColors.primaryIndigo.withValues(alpha: 0.5),
        textStyle: AppTextStyles.labelLarge,
      ),
      child: _buildChild(),
    );
  }

  /// Buton içeriğini oluşturur.
  Widget _buildChild() {
    // ── Loading durumu ──
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo),
        ),
      );
    }

    // ── İkon + metin ──
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    // ── Sadece metin ──
    return Text(text);
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

/// Tüm buton widget'ları için ortak davranışı sağlayan dahili base widget.
///
/// Bu widget doğrudan kullanılmamalıdır. Bunun yerine:
/// - [PrimaryButton]
/// - [SecondaryButton]
/// - [OutlineButton]
/// - [TextActionButton]
///
/// widget'larından biri kullanılmalıdır.
class BaseButton extends StatelessWidget {
  const BaseButton({
    required this.text,
    required this.onPressed,
    required this.style,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.loadingIndicatorColor = Colors.white,
    super.key,
  });

  /// Buton üzerinde gösterilecek metin.
  final String text;

  /// Butona tıklandığında çalışacak fonksiyon.
  final VoidCallback? onPressed;

  /// Butonun görünüm stili ([ButtonStyle]).
  final ButtonStyle style;

  /// Opsiyonel ikon — metnin solunda gösterilir.
  final IconData? icon;

  /// `true` ise buton tıklanamaz olur ve spinner gösterilir.
  final bool isLoading;

  /// `true` ise buton tıklanamaz (disabled) olur.
  final bool isDisabled;

  /// Loading spinner'ın rengi.
  final Color loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    // Loading veya disabled durumda onPressed null olur → buton tıklanamaz.
    final VoidCallback? effectiveOnPressed =
        (isLoading || isDisabled) ? null : onPressed;

    return ElevatedButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: _buildChild(),
    );
  }

  /// Buton içeriğini oluşturur.
  /// Loading durumunda spinner, normal durumda ikon + metin gösterir.
  Widget _buildChild() {
    // ── Loading durumu ──
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(loadingIndicatorColor),
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

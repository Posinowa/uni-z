import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

/// Şifre giriş alanı — göster/gizle toggle desteği ile.
///
/// Sağ taraftaki göz ikonu ile şifre görünürlüğü değiştirilebilir.
///
/// Örnek:
/// ```dart
/// AppPasswordField(
///   label: 'Şifre',
///   hint: 'Şifrenizi girin',
///   controller: _passwordController,
///   validator: (value) {
///     if (value == null || value.length < 6) return 'En az 6 karakter olmalı';
///     return null;
///   },
/// )
/// ```
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.onChanged,
    this.textInputAction,
    super.key,
  });

  /// Input üzerinde gösterilecek etiket metni.
  final String? label;

  /// Boşken gösterilecek ipucu metni.
  final String? hint;

  /// Metin değerini kontrol eden controller.
  final TextEditingController? controller;

  /// Form validasyonu için doğrulama fonksiyonu.
  final String? Function(String?)? validator;

  /// `false` ise input düzenlenemez.
  final bool enabled;

  /// Inputun sol tarafında gösterilecek ikon.
  final IconData? prefixIcon;

  /// Metin her değiştiğinde çağrılacak fonksiyon.
  final ValueChanged<String>? onChanged;

  /// Klavyedeki aksiyon butonu (next, done vb.).
  final TextInputAction? textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  /// Şifre gizli mi gösteriliyor mu durumunu tutar.
  bool _obscureText = true;

  /// Göster/gizle toggle'ını değiştirir.
  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      keyboardType: TextInputType.visiblePassword,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: AppTextStyles.labelMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
        // ── Göster/Gizle toggle butonu ──
        suffixIcon: IconButton(
          onPressed: _toggleVisibility,
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.primaryIndigo,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

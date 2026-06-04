import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

/// Uygulama genelinde kullanılacak standart metin giriş alanı.
///
/// App theme renklerini kullanır ve hata mesajı gösterebilir.
///
/// Örnek:
/// ```dart
/// AppTextField(
///   label: 'Ad Soyad',
///   hint: 'Adınızı girin',
///   controller: _nameController,
///   validator: (value) {
///     if (value == null || value.isEmpty) return 'Bu alan zorunludur';
///     return null;
///   },
/// )
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
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
  /// `null` dönerse geçerli, `String` dönerse hata mesajı gösterilir.
  final String? Function(String?)? validator;

  /// Klavye tipi (email, numara vb.).
  final TextInputType? keyboardType;

  /// Maksimum satır sayısı. Varsayılan: 1.
  final int maxLines;

  /// `false` ise input düzenlenemez.
  final bool enabled;

  /// Inputun sol tarafında gösterilecek ikon.
  final IconData? prefixIcon;

  /// Inputun sağ tarafında gösterilecek widget (ikon vb.).
  final Widget? suffixIcon;

  /// Metin her değiştiğinde çağrılacak fonksiyon.
  final ValueChanged<String>? onChanged;

  /// Klavyedeki aksiyon butonu (next, done vb.).
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      textInputAction: textInputAction,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.labelMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
        suffixIcon: suffixIcon,
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

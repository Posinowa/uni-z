import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

/// Açılır liste (dropdown) seçim alanı.
///
/// Generic tip `T` sayesinde String, enum veya model nesneleri ile
/// kullanılabilir.
///
/// Örnek:
/// ```dart
/// AppDropdownField<String>(
///   label: 'Üniversite',
///   hint: 'Üniversitenizi seçin',
///   value: _selectedUniversity,
///   items: universities.map((u) => DropdownMenuItem(
///     value: u.id,
///     child: Text(u.name),
///   )).toList(),
///   onChanged: (value) => setState(() => _selectedUniversity = value),
///   validator: (value) {
///     if (value == null) return 'Üniversite seçimi zorunludur';
///     return null;
///   },
/// )
/// ```
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.items,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    super.key,
  });

  /// Dropdown'da gösterilecek seçenekler.
  final List<DropdownMenuItem<T>> items;

  /// Input üzerinde gösterilecek etiket metni.
  final String? label;

  /// Seçim yapılmamışken gösterilecek ipucu metni.
  final String? hint;

  /// Şu an seçili olan değer.
  final T? value;

  /// Seçim değiştiğinde çağrılacak fonksiyon.
  final ValueChanged<T?>? onChanged;

  /// Form validasyonu için doğrulama fonksiyonu.
  final String? Function(T?)? validator;

  /// `false` ise dropdown düzenlenemez.
  final bool enabled;

  /// Inputun sol tarafında gösterilecek ikon.
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      dropdownColor: AppColors.surface,
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

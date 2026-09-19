import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Veri olmadığında gösterilecek boş durum widget'ı.
///
/// Liste boş olduğunda, arama sonuç döndürmediğinde vb.
/// kullanıcıya bilgilendirici bir görünüm sunar.
///
/// Örnek:
/// ```dart
/// if (posts.isEmpty) {
///   return AppEmptyState(
///     title: 'Henüz paylaşım yok',
///     description: 'İlk paylaşımı sen yap!',
///     icon: Icons.article_outlined,
///     actionText: 'Paylaşım Oluştur',
///     actionIcon: Icons.add,
///     onActionPressed: () => _createPost(),
///   );
/// }
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.description,
    this.icon,
    this.actionText,
    this.actionIcon,
    this.actionColor,
    this.onActionPressed,
    super.key,
  });

  /// Boş durum başlığı.
  final String title;

  /// Açıklama metni — başlığın altında gösterilir.
  final String? description;

  /// Başlığın üstünde gösterilecek ikon.
  final IconData? icon;

  /// Opsiyonel aksiyon butonu metni.
  /// [onActionPressed] ile birlikte kullanılmalıdır.
  final String? actionText;

  /// Opsiyonel aksiyon butonu ikonu.
  final IconData? actionIcon;

  /// Opsiyonel aksiyon butonu rengi (kenarlık ve metin için).
  /// Belirtilmezse varsayılan olarak [AppColors.primaryIndigo] kullanılır.
  final Color? actionColor;

  /// Aksiyon butonuna tıklandığında çalışacak fonksiyon.
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = actionColor ?? AppColors.primaryIndigo;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── İkon ──
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Başlık ──
              Text(
                title,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),

              // ── Açıklama ──
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],

              // ── Aksiyon butonu ──
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: AppSpacing.xl),
                if (actionIcon != null)
                  OutlinedButton.icon(
                    onPressed: onActionPressed,
                    icon: Icon(actionIcon, size: 18),
                    label: Text(actionText!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: effectiveColor,
                      side: BorderSide(color: effectiveColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: AppTextStyles.labelLarge,
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: onActionPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: effectiveColor,
                      side: BorderSide(color: effectiveColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: AppTextStyles.labelLarge,
                    ),
                    child: Text(actionText!),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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

  /// Aksiyon butonuna tıklandığında çalışacak fonksiyon.
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
              TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryIndigo,
                  textStyle: AppTextStyles.labelLarge,
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

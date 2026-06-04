import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Hata durumunu gösteren widget.
///
/// Veri çekilemediğinde veya bir işlem başarısız olduğunda
/// kullanıcıya hata mesajı ve opsiyonel tekrar dene butonu sunar.
///
/// Örnek:
/// ```dart
/// if (hasError) {
///   return AppErrorState(
///     title: 'Bir hata oluştu',
///     message: 'Veriler yüklenemedi. Lütfen tekrar deneyin.',
///     onRetry: () => _loadData(),
///   );
/// }
/// ```
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    this.message,
    this.onRetry,
    super.key,
  });

  /// Hata başlığı.
  final String title;

  /// Hata açıklama mesajı — başlığın altında gösterilir.
  final String? message;

  /// Tekrar dene butonuna tıklandığında çalışacak fonksiyon.
  /// `null` ise tekrar dene butonu gösterilmez.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Hata ikonu ──
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Başlık ──
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),

            // ── Mesaj ──
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],

            // ── Tekrar dene butonu ──
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryIndigo,
                  textStyle: AppTextStyles.labelLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

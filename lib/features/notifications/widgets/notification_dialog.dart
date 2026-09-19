import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Uygulama açıkken (foreground) gelen bildirimleri göstermek için kullanılan diyalog.
///
/// Uni'z tema renkleri ve tipografisi ile uyumludur.
/// "Görüntüle" butonuna tıklandığında [onTap] tetiklenir (varsayılan olarak ana sayfaya yönlendirir).
class NotificationDialog extends StatelessWidget {
  const NotificationDialog({
    super.key,
    required this.title,
    this.body,
    this.onTap,
  });

  /// Bildirim başlığı.
  final String title;

  /// Bildirim içeriği.
  final String? body;

  /// "Görüntüle" butonuna tıklandığında çağrılacak callback.
  final VoidCallback? onTap;

  /// Bildirim diyaloğunu gösteren yardımcı metot.
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? body,
    VoidCallback? onTap,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => NotificationDialog(
        title: title,
        body: body,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primaryIndigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: body != null && body!.isNotEmpty
          ? Text(
              body!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Kapat',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onTap?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryIndigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Görüntüle'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Uygulama açıkken (foreground) gelen bildirimleri göstermek için kullanılan SnackBar bileşeni.
///
/// Uni'z tema renklerine (`AppColors`, `AppTextStyles`) uygun olarak floating tarzda gösterilir.
/// Tıklandığında veya "Görüntüle" butonuna basıldığında [onTap] tetiklenir.
class InAppNotificationSnackBar {
  InAppNotificationSnackBar._();

  /// Tema uyumlu bir [SnackBar] nesnesi üretir.
  static SnackBar create({
    required String title,
    String? body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      duration: duration,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (body != null && body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      action: onTap != null
          ? SnackBarAction(
              label: 'Görüntüle',
              textColor: AppColors.primaryIndigo,
              onPressed: onTap,
            )
          : null,
    );
  }

  /// [BuildContext] kullanarak SnackBar'ı gösterir.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String title,
    String? body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      create(
        title: title,
        body: body,
        onTap: onTap,
        duration: duration,
      ),
    );
  }

  /// [ScaffoldMessengerState] kullanarak SnackBar'ı gösterir.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showWithMessenger(
    ScaffoldMessengerState messenger, {
    required String title,
    String? body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      create(
        title: title,
        body: body,
        onTap: onTap,
        duration: duration,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_model.dart';

/// Etkinlik listelerinde gösterilecek kart bileşeni.
///
/// Kart üzerinde:
/// - Görsel veya temaya uygun görsel placeholder'ı
/// - Etkinlik başlığı
/// - Etkinlik tarihi ve saati
/// - Konum bilgisi
/// - Organizatör bilgisi
/// yer alır.
class EventCard extends StatelessWidget {
  /// Gösterilecek etkinlik modeli.
  final EventModel event;

  /// Karta tıklandığında tetiklenecek geri çağrım (opsiyonel).
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Etkinlik Görseli veya Placeholder ─────────────────────
            _EventBanner(imageUrl: event.imageUrl),

            // ─── Etkinlik Detay İçeriği ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    event.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Tarih Satırı
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppColors.categoryEvents,
                    text: _formatDate(event.eventDate),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Konum Satırı
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.textSecondary,
                    text: event.location,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Organizatör Satırı
                  _InfoRow(
                    icon: Icons.groups_outlined,
                    iconColor: AppColors.textSecondary,
                    text: event.organizerName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarih verisini Türkçe ve okunabilir biçimde biçimlendirir.
  /// Örnek: "15 Ekim 2026, 14:00"
  static String _formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final monthName = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day} $monthName ${date.year}, $hour:$minute';
  }
}

/// Etkinlik görselini veya görsel olmadığında placeholder'ı gösteren bileşen.
class _EventBanner extends StatelessWidget {
  final String? imageUrl;

  const _EventBanner({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const bannerHeight = 140.0;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!.trim(),
        width: double.infinity,
        height: bannerHeight,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  /// Temaya uygun görsel placeholder konteyneri.
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 140.0,
      decoration: BoxDecoration(
        color: AppColors.categoryEvents.withValues(alpha: 0.08),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.categoryEvents,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 44,
                    color: AppColors.categoryEvents.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Etkinlik Görseli',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.categoryEvents.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// İkon ve metin içeren tek satırlık bilgi satırı.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

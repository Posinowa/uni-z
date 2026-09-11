import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_model.dart';
import '../widgets/event_detail_info_tile.dart';
import '../../reports/models/report_model.dart';
import '../../reports/models/report_target_type.dart';
import '../../reports/services/report_service.dart';

/// Kampüs etkinliğinin tüm detaylarının görüntülendiği ekran.
///
/// Gösterilen bilgiler:
/// - Görsel (imageUrl veya temaya uygun placeholder)
/// - Başlık (title)
/// - Tarih (eventDate gün/ay/yıl)
/// - Saat (eventDate saat:dakika)
/// - Konum (location)
/// - Organizatör (organizerName)
/// - Açıklama (description - taşmayı önleyecek şekilde kaydırılabilir)
/// - Rapor butonu (AppBar aksiyonunda ve sayfa altında)
///
/// Kapsam dışı:
/// - Katılacağım özelliği yoktur.
/// - Harita entegrasyonu yoktur.
class EventDetailScreen extends StatefulWidget {
  /// Sayfa route ismi sabiti.
  static const String routeName = '/event-detail';

  /// Gösterilecek etkinlik nesnesi.
  final EventModel? event;

  /// Rapor butonuna tıklandığında çalıştırılacak opsiyonel callback (test ve özel yönetim için).
  final void Function(BuildContext context, EventModel event)? onReport;

  /// Test edilebilirlik için opsiyonel servis ve auth enjeksiyonu.
  final ReportService? reportService;
  final FirebaseAuth? authInstance;

  const EventDetailScreen({
    super.key,
    this.event,
    this.onReport,
    this.reportService,
    this.authInstance,
  });

  /// [EventDetailScreen] sayfasına yönlendirme sağlayan standart [MaterialPageRoute] üretici.
  static Route<void> route({
    required EventModel event,
    void Function(BuildContext context, EventModel event)? onReport,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => EventDetailScreen(
        event: event,
        onReport: onReport,
      ),
    );
  }

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final ReportService _reportService;
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _reportService = widget.reportService ?? ReportService();
    _auth = widget.authInstance ?? FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    // Route argümanı veya doğrudan constructor parametresinden etkinlik modelini al
    final currentEvent = widget.event ??
        (ModalRoute.of(context)?.settings.arguments as EventModel?);

    if (currentEvent == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Etkinlik Detayı'),
        ),
        body: const Center(
          child: Text(
            'Etkinlik bilgisi bulunamadı.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final formattedDate = _formatDateOnly(currentEvent.eventDate);
    final formattedTime = _formatTimeOnly(currentEvent.eventDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Etkinlik Detayı'),
        actions: [
          IconButton(
            key: const Key('event_report_appbar_button'),
            icon: const Icon(
              Icons.flag_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Rapor Et',
            onPressed: () => _handleReport(context, currentEvent),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── 1. Etkinlik Görseli / Banner ────────────────────────
              _EventDetailBanner(imageUrl: currentEvent.imageUrl),

              // ─── 2. Detay İçerik Alanı ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      currentEvent.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ─── Tarih ve Saat Kartları (Yan Yana) ─────────────
                    Row(
                      children: [
                        Expanded(
                          child: EventDetailInfoTile(
                            label: 'Tarih',
                            value: formattedDate,
                            icon: Icons.calendar_today_outlined,
                            iconColor: AppColors.categoryEvents,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: EventDetailInfoTile(
                            label: 'Saat',
                            value: formattedTime,
                            icon: Icons.access_time_outlined,
                            iconColor: AppColors.categoryEvents,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ─── Konum Kartı ──────────────────────────────────
                    EventDetailInfoTile(
                      label: 'Konum',
                      value: currentEvent.location,
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.primaryIndigo,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ─── Organizatör Kartı ────────────────────────────
                    EventDetailInfoTile(
                      label: 'Organizatör',
                      value: currentEvent.organizerName,
                      icon: Icons.groups_outlined,
                      iconColor: AppColors.secondaryCyan,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ─── Açıklama Bölümü ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Etkinlik Hakkında',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currentEvent.description.trim().isNotEmpty
                                ? currentEvent.description
                                : 'Bu etkinlik için henüz bir açıklama eklenmedi.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ─── Rapor Butonu (Sayfa İçi Aksiyon) ──────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('event_report_action_button'),
                        onPressed: () => _handleReport(context, currentEvent),
                        icon: const Icon(
                          Icons.flag_outlined,
                          size: 18,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'Etkinliği Rapor Et',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Raporlama akışını tetikler.
  void _handleReport(BuildContext context, EventModel currentEvent) {
    if (widget.onReport != null) {
      widget.onReport!(context, currentEvent);
      return;
    }

    _showReportBottomSheet(context, currentEvent);
  }

  /// PROJECT_CONTEXT.md Bölüm 18'de belirtilen rapor nedenlerini listeleyen modal.
  /// Sebep seçildiğinde Firestore `reports` koleksiyonuna `targetType: event` olarak kaydeder.
  void _showReportBottomSheet(BuildContext context, EventModel currentEvent) {
    const reportReasons = [
      'Uygunsuz içerik',
      'Yanlış bilgi',
      'Spam',
      'Telif hakkı ihlali',
      'Hakaret / saldırgan içerik',
      'Diğer',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        // Bottom sheet içi loading state'ini yönetmek için StatefulBuilder kullanılır.
        // Bu sayede sebep seçildiğinde çift tıklama engellenir.
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: AppColors.error,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Etkinliği Rapor Et',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'Lütfen bu etkinliği neden bildirmek istediğinizi seçin:',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Divider(height: AppSpacing.xl),
                    ...reportReasons.map(
                      (reason) => ListTile(
                        dense: true,
                        enabled: !isSubmitting,
                        title: Text(
                          reason,
                          style: AppTextStyles.bodyMedium,
                        ),
                        trailing: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.categoryReport,
                                ),
                              )
                            : const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                        onTap: () async {
                          // Kullanıcı giriş yapmamışsa işlem yapma
                          final uid = _auth.currentUser?.uid;
                          if (uid == null) return;

                          setSheetState(() => isSubmitting = true);

                          try {
                            final report = ReportModel(
                              id: '',
                              targetType: ReportTargetType.event,
                              targetId: currentEvent.id,
                              reportedBy: uid,
                              reason: reason,
                            );

                            await _reportService.createReport(report);

                            if (!context.mounted) return;
                            Navigator.pop(bottomSheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Raporunuz alındı. Teşekkür ederiz.'),
                                backgroundColor: AppColors.categoryReport,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } on StateError {
                            // Aynı kullanıcı aynı etkinliği zaten raporlamış
                            if (!context.mounted) return;
                            Navigator.pop(bottomSheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Bu etkinliği zaten raporladınız.',
                                ),
                                backgroundColor: AppColors.warning,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(bottomSheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Bir hata oluştu: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Tarih kısmını Türkçe ay adıyla biçimlendirir (Örn: "15 Ekim 2026").
  static String _formatDateOnly(DateTime date) {
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
    return '${date.day} $monthName ${date.year}';
  }

  /// Saat kısmını "14:00" formatında biçimlendirir.
  static String _formatTimeOnly(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Etkinlik detay ekranının üstündeki görsel banner veya placeholder bileşeni.
class _EventDetailBanner extends StatelessWidget {
  final String? imageUrl;

  const _EventDetailBanner({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const bannerHeight = 220.0;

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

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 220.0,
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
                    size: 56,
                    color: AppColors.categoryEvents.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Etkinlik Görseli',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.categoryEvents.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

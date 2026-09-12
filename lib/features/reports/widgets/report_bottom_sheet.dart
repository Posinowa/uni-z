import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/report_model.dart';
import '../models/report_target_type.dart';
import '../services/report_service.dart';

/// İçerik raporlama için ortak bottom sheet bileşeni.
///
/// Kullanım:
/// ```dart
/// ReportBottomSheet.show(
///   context: context,
///   targetId: materialId,
///   targetType: ReportTargetType.material,
/// );
/// ```
///
/// Kullanıcı bir sebep seçip "Raporla" butonuna bastığında
/// [ReportService.createReport] çağrılır ve rapor Firestore'a kaydedilir.
/// Aynı kullanıcı aynı içeriği tekrar raporlamaya çalışırsa hata mesajı gösterilir.
class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  /// Raporlanan içeriğin Firestore ID'si.
  final String targetId;

  /// Raporlanan içerik türü (material, post, event, user).
  final ReportTargetType targetType;

  /// Bottom sheet'i gösterir.
  static Future<void> show({
    required BuildContext context,
    required String targetId,
    required ReportTargetType targetType,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (_) => ReportBottomSheet(
        targetId: targetId,
        targetType: targetType,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _reportService = ReportService();

  /// Seçili sebep indeksi. null = henüz seçilmedi.
  int? _selectedReasonIndex;

  /// Gönderim sırasında true olur.
  bool _isLoading = false;

  /// Raporlama sebepleri.
  static const List<String> _reasons = [
    'Telif hakkı ihlali',
    'Yanıltıcı veya yanlış bilgi',
    'Uygunsuz içerik',
    'Spam',
    'Diğer',
  ];

  Future<void> _onSubmit() async {
    if (_selectedReasonIndex == null) return;

    // Giriş yapmış kullanıcının UID'sini al
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) {
      _showSnackBar(
        ScaffoldMessenger.of(context),
        'Raporlamak için giriş yapmanız gerekiyor.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final report = ReportModel(
        id: '',
        targetType: widget.targetType,
        targetId: widget.targetId,
        reportedBy: userId,
        reason: _reasons[_selectedReasonIndex!],
        createdAt: DateTime.now(),
      );

      await _reportService.createReport(report);

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      _showSnackBar(
        messenger,
        'Raporunuz alındı. İncelendikten sonra işlem yapılacaktır.',
      );
    } on StateError catch (e) {
      // Duplicate rapor — ReportService StateError fırlatır
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      _showSnackBar(messenger, e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        ScaffoldMessenger.of(context),
        'Bir hata oluştu. Lütfen tekrar deneyin.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(
    ScaffoldMessengerState messenger,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Klavye açıldığında içerik yukarı kaymasın diye
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tutamaç çubuğu ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Başlık ──
              Text(
                'İçeriği Raporla',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bu içeriği neden raporlamak istiyorsunuz?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Sebep Listesi ──
              ...List.generate(_reasons.length, (index) {
                final isSelected = _selectedReasonIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedReasonIndex = index);
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryIndigo.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryIndigo
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? AppColors.primaryIndigo
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            _reasons[index],
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primaryIndigo
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.md),

              // ── Raporla Butonu ──
              FilledButton(
                onPressed: _selectedReasonIndex != null && !_isLoading
                    ? _onSubmit
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Raporla',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

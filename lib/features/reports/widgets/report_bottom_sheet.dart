import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/report_model.dart';
import '../models/report_status.dart';
import '../models/report_target_type.dart';
import '../services/report_service.dart';

/// Kullanıcının bir postu raporlamasını sağlayan bottom sheet.
///
/// [postId] raporlanacak postun Firestore kimliği.
/// [reportedBy] raporu oluşturan kullanıcının kimliği.
///
/// Kullanım:
/// ```dart
/// showReportBottomSheet(
///   context: context,
///   postId: post.id,
///   reportedBy: currentUserId,
/// );
/// ```
Future<void> showReportBottomSheet({
  required BuildContext context,
  required String postId,
  required String reportedBy,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReportBottomSheet(
      postId: postId,
      reportedBy: reportedBy,
    ),
  );
}

/// Rapor seçeneklerini listeleyen bottom sheet içeriği.
class _ReportBottomSheet extends StatefulWidget {
  final String postId;
  final String reportedBy;

  const _ReportBottomSheet({
    required this.postId,
    required this.reportedBy,
  });

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  /// Kullanıcının seçtiği rapor nedeni.
  String? _selectedReason;

  /// Opsiyonel açıklama alanı için controller.
  final TextEditingController _descriptionController = TextEditingController();

  /// Gönderim işlemi devam ederken true olur, butonu devre dışı bırakır.
  bool _isLoading = false;

  final ReportService _reportService = ReportService();

  /// Kullanıcının seçebileceği rapor nedenleri.
  static const List<String> _reasons = [
    'Uygunsuz içerik',
    'Yanlış bilgi',
    'Spam',
    'Telif hakkı ihlali',
    'Hakaret / saldırgan içerik',
    'Diğer',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Raporu Firestore'a gönderir.
  Future<void> _submit() async {
    // Neden seçilmemişse gönderme.
    if (_selectedReason == null) return;

    setState(() => _isLoading = true);

    final report = ReportModel(
      id: '',
      targetType: ReportTargetType.post,
      targetId: widget.postId,
      reportedBy: widget.reportedBy,
      reason: _selectedReason!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      status: ReportStatus.open,
      createdAt: DateTime.now(),
    );

    try {
      await _reportService.createReport(report);

      if (!mounted) return;
      Navigator.of(context).pop();

      // Başarılı bildirimi göster.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Raporunuz alındı. Teşekkür ederiz.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on StateError catch (e) {
      // Aynı kullanıcı aynı içeriği tekrar raporlamaya çalışıyor.
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.warning,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      // Klavye açıldığında bottom sheet yukarı kayar.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Başlık ──────────────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    color: AppColors.categoryReport,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Gönderiyi Raporla',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bu gönderiyi neden raporluyorsunuz?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ─── Neden Listesi ───────────────────────────────────
              ..._reasons.map((reason) => _ReasonTile(
                    reason: reason,
                    isSelected: _selectedReason == reason,
                    onTap: () => setState(() => _selectedReason = reason),
                  )),

              const SizedBox(height: AppSpacing.lg),

              // ─── Açıklama Alanı (opsiyonel) ─────────────────────
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Ek açıklama (opsiyonel)',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                    borderSide: const BorderSide(
                      color: AppColors.primaryIndigo,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ─── Gönder Butonu ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selectedReason == null || _isLoading)
                      ? null
                      : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.categoryReport,
                    disabledBackgroundColor: AppColors.border,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Raporla',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tekil rapor nedeni satırı.
class _ReasonTile extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.categoryReport.withAlpha(15)
              : AppColors.background,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.categoryReport : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppColors.categoryReport
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.categoryReport,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

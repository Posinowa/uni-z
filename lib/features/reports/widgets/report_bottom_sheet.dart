import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/banned_action_guard.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/report_model.dart';
import '../models/report_reason.dart';
import '../models/report_target_type.dart';
import '../services/report_service.dart';

/// Bir içeriği (gönderi, materyal, etkinlik vb.) raporlamak için
/// kullanıcıya sebep seçtiren bottom sheet.
///
/// Kullanıcı giriş yapmamışsa bottom sheet açılmamalıdır.
class ReportBottomSheet extends StatefulWidget {
  /// Raporlanacak içeriğin Firestore belgesi kimliği.
  final String targetId;

  /// Rapor hedef tipi (post, material, event, user).
  final ReportTargetType targetType;

  /// Bottom sheet başlığı (opsiyonel; null ise targetType'a göre belirlenir).
  final String? title;

  /// Geriye dönük uyumluluk için postId getter'ı.
  String get postId => targetId;

  /// Rapor servis enjeksiyonu. Test edilebilirlik için dışarıdan geçilebilir.
  final ReportService? reportService;

  /// Hata gözlemlenebilirliği ve crash reporting için opsiyonel hata kancası (hook).
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ReportBottomSheet({
    super.key,
    String? postId,
    String? targetId,
    this.targetType = ReportTargetType.post,
    this.title,
    this.reportService,
    this.onError,
  })  : targetId = targetId ?? postId ?? '';

  /// Bottom sheet'i gösterir.
  ///
  /// Ön kontroller:
  /// 1. Banlı kullanıcı kontrolü ([BannedActionGuard]).
  /// 2. Duplicate kontrolü ([ReportService.hasUserReported]) — kullanıcı bu içeriği
  ///    zaten raporlamışsa bottom sheet açılmadan kullanıcıya bilgi SnackBar'ı gösterilir.
  static Future<void> show(
    BuildContext context, {
    String? postId,
    String? targetId,
    ReportTargetType targetType = ReportTargetType.post,
    String? title,
    ReportService? reportService,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) async {
    final resolvedTargetId = targetId ?? postId ?? '';
    if (resolvedTargetId.isEmpty) return;

    // Ban kontrolü — banlı kullanıcı rapor gönderemez
    if (!await BannedActionGuard.check(context)) return;
    if (!context.mounted) return;

    // Duplicate kontrolü — kullanıcı bu içeriği daha önce raporlamış mı?
    final currentUserId =
        context.read<AuthProvider>().currentUser?.uid ?? '';
    final service = reportService ?? ReportService();
    if (currentUserId.isNotEmpty) {
      try {
        final alreadyReported = await service.hasUserReported(
          targetType: targetType.value,
          targetId: resolvedTargetId,
          userId: currentUserId,
        );
        if (alreadyReported) {
          if (!context.mounted) return;
          final msg = targetType == ReportTargetType.material
              ? 'Bu materyali daha önce raporladınız.'
              : 'Bu içeriği daha önce raporladınız.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      } catch (_) {
        // Kontrol sırasında ağ/firestore hatası olursa akışı engellemiyoruz,
        // submit anında deterministic docId ile Firestore idempotent koruma sağlayacaktır.
      }
    }

    if (!context.mounted) return;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReportBottomSheet(
        targetId: resolvedTargetId,
        targetType: targetType,
        title: title,
        reportService: reportService,
        onError: onError,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  late final ReportService _reportService;

  /// Seçili rapor sebebi enum'ı. Kullanıcı seçmeden submit edemez.
  ReportReason? _selectedReason;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reportService = widget.reportService ?? ReportService();
  }

  // Rapor sebepleri enum listesi.
  static const List<ReportReason> _reasons = ReportReason.values;

  Future<void> _submit() async {
    final selectedReason = _selectedReason;
    if (selectedReason == null) return;

    final currentUserId =
        context.read<AuthProvider>().currentUser?.uid ?? '';

    // Servis katmanı zaten kontrol eder; UI'da da güvenlik katmanı.
    if (currentUserId.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    // Ban kontrolü — banlı kullanıcı rapor gönderemez
    if (!await BannedActionGuard.check(context, userId: currentUserId)) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final report = ReportModel(
        id: '',
        targetType: widget.targetType,
        targetId: widget.targetId,
        reportedBy: currentUserId,
        reason: selectedReason.value,
        createdAt: DateTime.now(),
      );

      await _reportService.createReport(report);

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Raporunuz alındı. İncelenecek.'),
          backgroundColor: AppColors.primaryIndigo,
        ),
      );
    } on StateError catch (e) {
      // Aynı içerik zaten raporlanmış.
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e, stackTrace) {
      widget.onError?.call(e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapor gönderilemedi. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _resolveTitle() {
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    switch (widget.targetType) {
      case ReportTargetType.material:
        return 'Materyali Raporla';
      case ReportTargetType.event:
        return 'Etkinliği Raporla';
      case ReportTargetType.user:
        return 'Kullanıcıyı Raporla';
      case ReportTargetType.post:
        return 'Gönderiyi Raporla';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Başlık ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              _resolveTitle(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),

          // ─── Sebep Listesi ────────────────────────────────────
          RadioGroup<ReportReason>(
            groupValue: _selectedReason,
            onChanged: (value) {
              if (value != null) setState(() => _selectedReason = value);
            },
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reasons.length,
              itemBuilder: (context, index) {
                final reason = _reasons[index];
                return RadioListTile<ReportReason>(
                  title: Text(reason.label),
                  value: reason,
                  activeColor: AppColors.primaryIndigo,
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ─── Gönder Butonu ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_selectedReason == null || _isLoading)
                    ? null
                    : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Raporla'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

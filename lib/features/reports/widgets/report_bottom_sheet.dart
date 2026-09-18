import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/report_model.dart';
import '../models/report_target_type.dart';
import '../services/report_service.dart';

/// Bir içeriği raporlamak için kullanıcıya sebep seçtiren bottom sheet.
///
/// Kullanıcı giriş yapmamışsa bottom sheet açılmamalıdır.
/// Açılırken [postId] geçilmesi zorunludur.
class ReportBottomSheet extends StatefulWidget {
  /// Raporlanacak post'un Firestore belgesi kimliği.
  final String postId;

  const ReportBottomSheet({super.key, required this.postId});

  /// Bottom sheet'i gösterir.
  ///
  /// Dışarıdan çağrılacak yardımcı metod.
  static Future<void> show(BuildContext context, {required String postId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReportBottomSheet(postId: postId),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final ReportService _reportService = ReportService();

  /// Seçili rapor sebebi. Kullanıcı seçmeden submit edemez.
  String? _selectedReason;

  bool _isLoading = false;

  // Rapor sebepleri listesi.
  static const List<String> _reasons = [
    'Uygunsuz içerik',
    'Spam veya yanıltıcı',
    'Nefret söylemi',
    'Taciz veya zorbalık',
    'Telif hakkı ihlali',
    'Diğer',
  ];

  Future<void> _submit() async {
    final reason = _selectedReason;
    if (reason == null) return;

    final currentUserId =
        context.read<AuthProvider>().currentUser?.uid ?? '';

    // Servis katmanı zaten kontrol eder; UI'da da güvenlik katmanı.
    if (currentUserId.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final report = ReportModel(
        id: '',
        targetType: ReportTargetType.post,
        targetId: widget.postId,
        reportedBy: currentUserId,
        reason: reason,
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
    } catch (_) {
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
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              'Gönderiyi Raporla',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),

          // ─── Sebep Listesi ────────────────────────────────────
          RadioGroup<String>(
            groupValue: _selectedReason ?? '',
            onChanged: (value) {
              if (value != null) setState(() => _selectedReason = value);
            },
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reasons.length,
              itemBuilder: (context, index) {
                final reason = _reasons[index];
                return RadioListTile<String>(
                  title: Text(reason),
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

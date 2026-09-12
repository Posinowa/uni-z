import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/states/app_empty_state.dart';
import '../services/course_material_service.dart';
import '../../../features/reports/models/report_target_type.dart';
import '../../../features/reports/widgets/report_bottom_sheet.dart';
import 'material_card.dart';

/// Ders detay ekranındaki "Materyaller" sekmesini temsil eden widget.
///
/// Firestore'dan sadece `status: approved` olan materyalleri dinler
/// ve [MaterialCard] ile listeler.
/// Materyal yoksa [AppEmptyState] gösterilir.
class CourseMaterialsTab extends StatefulWidget {
  const CourseMaterialsTab({
    super.key,
    required this.courseId,
    required this.onUploadPressed,
  });

  /// Materyallerin ait olduğu dersin Firestore ID'si.
  final String courseId;

  /// Materyal yükle butonuna basıldığında tetiklenecek fonksiyon.
  final VoidCallback onUploadPressed;

  @override
  State<CourseMaterialsTab> createState() => _CourseMaterialsTabState();
}

class _CourseMaterialsTabState extends State<CourseMaterialsTab> {
  final _service = CourseMaterialService();

  int _selectedFilterIndex = 0;

  /// Filtre indeksine karşılık gelen Firestore type değerleri.
  /// null = tümü (filtre uygulanmaz).
  static const List<String?> _filterTypes = [
    null,           // Tümü
    'lecture_note', // Ders Notları
    'past_exam',    // Çıkmış Sorular
    'summary',      // Özetler
    'other',        // Diğer
  ];

  static const List<String> _filterLabels = [
    'Tümü',
    'Ders Notları',
    'Çıkmış Sorular',
    'Özetler',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchApprovedMaterials(widget.courseId),
      builder: (context, snapshot) {
        // ── Yükleniyor ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Hata ──
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Materyaller yüklenirken bir hata oluştu.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final allDocs = snapshot.data?.docs ?? [];

        // Seçili filtreye göre dökümanları filtrele
        final selectedType = _filterTypes[_selectedFilterIndex];
        final docs = selectedType == null
            ? allDocs
            : allDocs
                .where((doc) => doc.data()['type'] == selectedType)
                .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Kategori Filtre Çipleri ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filterLabels.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(_filterLabels[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFilterIndex = index);
                          }
                        },
                        selectedColor: AppColors.primaryIndigo,
                        backgroundColor: AppColors.surface,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryIndigo
                                : AppColors.border,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Liste veya Boş Durum ──
              if (docs.isEmpty)
                _buildEmptyState()
              else
                ...docs.map((doc) {
                  final data = doc.data();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: MaterialCard(
                      title: data['title'] as String? ?? '',
                      type: data['type'] as String? ?? 'other',
                      fileType: data['fileType'] as String? ?? '',
                      createdAt: data['createdAt'] as Timestamp?,
                      onReportTap: () {
                        ReportBottomSheet.show(
                          context: context,
                          targetId: doc.id,
                          targetType: ReportTargetType.material,
                        );
                      },
                    ),
                  );
                }),

              const SizedBox(height: AppSpacing.xl),

              // ── Bilgilendirici İpucu Notu ──
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.primaryIndigo,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Yüklenen materyaller telif ve içerik kontrollerinin ardından yayınlanır.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  /// Materyal bulunamadığında gösterilen boş durum bileşeni.
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          AppEmptyState(
            title: 'Henüz materyal bulunmuyor',
            description:
                'Bu ders için ilk ders notunu, çıkmış soruyu veya özeti sen yükleyerek arkadaşlarına destek ol!',
            icon: Icons.folder_open_outlined,
          ),
          const SizedBox(height: AppSpacing.xl),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: PrimaryButton(
              text: 'Materyal Yükle',
              icon: Icons.upload_file_outlined,
              onPressed: widget.onUploadPressed,
            ),
          ),
        ],
      ),
    );
  }
}

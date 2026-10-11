import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/states/app_empty_state.dart';
import '../models/course_material.dart';
import '../services/course_material_service.dart';
import 'material_card.dart';

/// Ders detay ekranındaki "Materyaller" sekmesini temsil eden widget.
///
/// [courseId] ile `watchApprovedMaterials` stream'ini dinler ve
/// onaylanmış materyalleri [MaterialCard] widget'ları ile listeler.
/// Materyaller tür filtre çipleri ile client-side filtrelenebilir.
/// Veri yoksa kullanıcıya bilgilendirici bir empty state ve
/// "Materyal Yükle" CTA butonu gösterilir.
///
/// Pending / rejected materyaller Firestore query'si tarafından
/// filtrelenir, UI'a hiç ulaşmaz.
class CourseMaterialsTab extends StatefulWidget {
  const CourseMaterialsTab({
    super.key,
    required this.courseId,
    required this.onUploadPressed,
  });

  /// Materyallerin dinleneceği dersin Firestore belge ID'si.
  final String courseId;

  /// Materyal yükle butonuna basıldığında tetiklenecek fonksiyon.
  final VoidCallback onUploadPressed;

  @override
  State<CourseMaterialsTab> createState() => _CourseMaterialsTabState();
}

class _CourseMaterialsTabState extends State<CourseMaterialsTab> {
  int _selectedFilterIndex = 0;

  /// Filtre chip seçenekleri.
  /// [type] null → "Tümü" (filtre yok).
  static const List<_FilterOption> _filters = [
    _FilterOption(label: 'Tümü', type: null),
    _FilterOption(label: 'Ders Notları', type: 'lecture_note'),
    _FilterOption(label: 'Çıkmış Sorular', type: 'past_exam'),
    _FilterOption(label: 'Özetler', type: 'summary'),
    _FilterOption(label: 'Diğer', type: 'other'),
  ];

  late final CourseMaterialService _materialService;

  @override
  void initState() {
    super.initState();
    _materialService = CourseMaterialService();
  }

  /// Seçili filtreye göre materyalleri client-side filtreler.
  List<CourseMaterial> _applyFilter(List<CourseMaterial> materials) {
    final selectedType = _filters[_selectedFilterIndex].type;
    if (selectedType == null) return materials; // "Tümü" seçili
    return materials.where((m) => m.type.value == selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CourseMaterial>>(
      stream: _materialService.watchApprovedMaterials(widget.courseId),
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Kategori Filtre Çipleri ──
              _buildFilterChips(),
              const SizedBox(height: AppSpacing.xl),

              // ── İçerik: Loading / Error / Liste / Empty State ──
              _buildContent(snapshot),
              const SizedBox(height: AppSpacing.xl),

              // ── Bilgilendirici İpucu Notu ──
              _buildInfoNote(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  /// Filtre chip satırını oluşturur.
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_filters[index].label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilterIndex = index);
                }
              },
              selectedColor: AppColors.primaryIndigo,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
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
    );
  }

  /// Stream durumuna göre içerik widget'ı döndürür.
  Widget _buildContent(AsyncSnapshot<List<CourseMaterial>> snapshot) {
    // ── Yükleniyor ──
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryIndigo,
          ),
        ),
      );
    }

    // ── Hata ──
    if (snapshot.hasError) {
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
        child: AppEmptyState(
          title: 'Materyaller yüklenirken bir hata oluştu',
          description: 'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
          icon: Icons.error_outline,
        ),
      );
    }

    // ── Veri geldi ──
    final allMaterials = snapshot.data ?? [];
    final filteredMaterials = _applyFilter(allMaterials);

    // Hiç materyal yok (veya filtrelenmiş liste boş)
    if (filteredMaterials.isEmpty) {
      return _buildEmptyState(isFiltered: allMaterials.isNotEmpty);
    }

    // ── Materyal Listesi ──
    return Column(
      children: List.generate(filteredMaterials.length, (index) {
        final material = filteredMaterials[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < filteredMaterials.length - 1
                ? AppSpacing.sm
                : 0,
          ),
          child: MaterialCard(
            title: material.title,
            type: material.type.value,
            fileType: material.fileType,
            createdAt: material.createdAt,
            onReportTap: () {
              // TODO: Rapor akışı ayrı issue'da geliştirilecek
            },
          ),
        );
      }),
    );
  }

  /// Materyal bulunmadığında gösterilecek empty state.
  ///
  /// [isFiltered] true ise filtre sonucu boş, false ise hiç materyal yok demektir.
  Widget _buildEmptyState({required bool isFiltered}) {
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
            title: isFiltered
                ? 'Bu kategoride materyal bulunmuyor'
                : 'Henüz materyal bulunmuyor',
            description: isFiltered
                ? 'Farklı bir filtre seçmeyi deneyin veya bu kategoride ilk materyali yükleyin.'
                : 'Bu ders için ilk ders notunu, çıkmış soruyu veya özeti sen yükleyerek arkadaşlarına destek ol!',
            icon: isFiltered
                ? Icons.filter_list_off
                : Icons.folder_open_outlined,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Materyal Yükle Butonu ──
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

  /// Alt bilgilendirici ipucu notu.
  Widget _buildInfoNote() {
    return Container(
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
    );
  }
}

/// Filtre seçeneği yardımcı sınıfı.
/// [type] null ise "Tümü" anlamına gelir (filtre uygulanmaz).
class _FilterOption {
  final String label;
  final String? type;

  const _FilterOption({required this.label, required this.type});
}

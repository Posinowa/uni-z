import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../widgets/course_detail_args.dart';
import '../widgets/course_info_card.dart';
import '../widgets/course_materials_tab.dart';
import 'upload_material_screen.dart';

/// Ders Detay Ekranı.
///
/// Gösterilen öğeler:
/// - Ders kodu (Rozet şeklinde)
/// - Ders adı
/// - Açıklama
/// - Üniversite / bölüm
/// - Materyaller sekmesi
/// - Materyal yükle butonu
///
/// Route ile açılış:
/// ```dart
/// Navigator.pushNamed(
///   context,
///   CourseDetailScreen.routeName,
///   arguments: CourseDetailArgs(...),
/// );
/// ```
/// veya doğrudan:
/// ```dart
/// Navigator.push(context, CourseDetailScreen.route(args: CourseDetailArgs(...)));
/// ```
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    this.args,
  });

  /// Ekran açılırken opsiyonel olarak iletilen ders verileri.
  final CourseDetailArgs? args;

  /// Bu ekran için tanımlanmış rota adı.
  static const String routeName = '/course-detail';

  /// Kolay ve tip-güvenli rota oluşturucu yardımcı metod.
  static Route<dynamic> route({CourseDetailArgs? args}) {
    return MaterialPageRoute<dynamic>(
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
      builder: (_) => CourseDetailScreen(args: args),
    );
  }

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  CourseDetailArgs? _resolvedArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveArguments();
  }

  /// Ekran parametrelerini öncelik sırasına göre çözümler:
  /// 1. Widget üzerinden doğrudan iletilen [widget.args]
  /// 2. [ModalRoute.settings.arguments] ile iletilen [CourseDetailArgs] veya [Map]
  /// 3. Hiçbiri yoksa varsayılan güvenli örnek veri ([CourseDetailArgs.defaultCourse])
  void _resolveArguments() {
    if (widget.args != null) {
      _resolvedArgs = widget.args;
      return;
    }

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is CourseDetailArgs) {
      _resolvedArgs = routeArgs;
    } else if (routeArgs is Map<String, dynamic>) {
      _resolvedArgs = CourseDetailArgs.fromMap(routeArgs);
    } else {
      _resolvedArgs ??= CourseDetailArgs.defaultCourse();
    }
  }

  /// Materyal yükle butonuna tıklandığında çalışacak işlem.
  /// Kullanıcıyı [UploadMaterialScreen] ekranına yönlendirir.
  void _onUploadMaterialPressed() {
    Navigator.push(
      context,
      UploadMaterialScreen.route(courseArgs: _resolvedArgs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _resolvedArgs ?? CourseDetailArgs.defaultCourse();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            args.courseCode.isNotEmpty ? args.courseCode : 'Ders Detayı',
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // ── Üst Bilgi Kartı ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: CourseInfoCard(
                courseCode: args.courseCode,
                courseName: args.courseName,
                universityName: args.universityName,
                departmentName: args.departmentName,
                description: args.description,
              ),
            ),

            // ── Sekme Çubuğu (TabBar) ──
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: TabBar(
                labelColor: AppColors.primaryIndigo,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primaryIndigo,
                indicatorWeight: 3,
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.labelLarge,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.folder_outlined, size: 20),
                    text: 'Materyaller',
                  ),
                  Tab(
                    icon: Icon(Icons.info_outline, size: 20),
                    text: 'Hakkında',
                  ),
                ],
              ),
            ),

            // ── Sekme İçerikleri ──
            Expanded(
              child: TabBarView(
                children: [
                  // Sekme 1: Materyaller
                  CourseMaterialsTab(
                    onUploadPressed: _onUploadMaterialPressed,
                  ),

                  // Sekme 2: Hakkında / Bilgiler
                  _buildAboutTab(args),
                ],
              ),
            ),
          ],
        ),

        // ── Sabit Alt Materyal Yükle Butonu ──
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: PrimaryButton(
              text: 'Materyal Yükle',
              icon: Icons.upload_file_outlined,
              onPressed: _onUploadMaterialPressed,
            ),
          ),
        ),
      ),
    );
  }

  /// "Hakkında" sekmesi içeriği.
  Widget _buildAboutTab(CourseDetailArgs args) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genel Bilgiler',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            icon: Icons.code,
            label: 'Ders Kodu',
            value: args.courseCode,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            icon: Icons.book_outlined,
            label: 'Ders Adı',
            value: args.courseName,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            icon: Icons.account_balance_outlined,
            label: 'Üniversite',
            value: args.universityName,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            icon: Icons.school_outlined,
            label: 'Bölüm',
            value: args.departmentName,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Telif ve Uyarı Kutusu (PROJECT_CONTEXT.md Bölüm 20) ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.warning,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Ders materyallerini yüklerken yalnızca paylaşım hakkına sahip olduğunuz içerikleri paylaşınız. Telif hakkı içeren veya izinsiz belgeler sistemden kaldırılacaktır.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryIndigo),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

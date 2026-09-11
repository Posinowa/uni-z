import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'course_detail_screen.dart';
import 'suggest_course_screen.dart';
import 'upload_material_screen.dart';

/// Geçici dersler ekranı.
///
/// Ders listeleme özelliği ileride ayrı bir issue'da geliştirilecektir.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dersler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ders Öner',
            onPressed: () {
              Navigator.push(
                context,
                SuggestCourseScreen.route(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: AppColors.primaryIndigo,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Dersler Ekranı',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yakında burada dersler ve materyaller yer alacak.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  CourseDetailScreen.route(),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Örnek Ders Detayını Gör'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  SuggestCourseScreen.route(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Ders Öner'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryIndigo,
                side: const BorderSide(color: AppColors.primaryIndigo),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  UploadMaterialScreen.route(),
                );
              },
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Materyal Yükle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryIndigo,
                side: const BorderSide(color: AppColors.primaryIndigo),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

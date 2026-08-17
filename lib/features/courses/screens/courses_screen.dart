import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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
          ],
        ),
      ),
    );
  }
}

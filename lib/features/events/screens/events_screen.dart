import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Geçici etkinlikler ekranı.
///
/// Etkinlik listeleme özelliği ileride ayrı bir issue'da geliştirilecektir.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_outlined,
              size: 64,
              color: AppColors.primaryIndigo,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Etkinlikler Ekranı',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yakında burada kampüs etkinlikleri yer alacak.',
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

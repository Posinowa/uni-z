import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../profile/widgets/logout_button.dart';

/// Geçici akış (Home/Feed) ekranı.
///
/// Sosyal akışı ve üst barda veya ekran içinde oturumu kapatma butonunu barındırır.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uni'z Akış"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.dynamic_feed_outlined,
                size: 64,
                color: AppColors.primaryIndigo,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Akış Ekranı',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Yakında burada kampüs paylaşımları yer alacak.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(
                width: 200,
                child: LogoutButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

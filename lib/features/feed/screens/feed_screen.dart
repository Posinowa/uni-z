import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/feed_post.dart';
import '../models/post_type.dart';
import '../services/feed_service.dart';

/// Ana sosyal akış (Feed) ekranı.
///
/// Firestore `posts` koleksiyonundaki yayınlanmış gönderileri anlık olarak dinler
/// ve listeler.
class FeedScreen extends StatefulWidget {
  final FeedService? feedService;

  const FeedScreen({this.feedService, super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final FeedService _feedService;

  @override
  void initState() {
    super.initState();
    _feedService = widget.feedService ?? FeedService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Uni'z Akış"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<FeedPost>>(
          stream: _feedService.watchFeedPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Gönderiler yüklenirken bir hata oluştu.',
                        style: AppTextStyles.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${snapshot.error}',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final posts = snapshot.data ?? [];

            if (posts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
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
                        'Henüz gönderi yok',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Paylaş sekmesinden ilk gönderini oluşturabilirsin!',
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

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: posts.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final post = posts[index];
                return _FeedPostCard(post: post);
              },
            );
          },
        ),
      ),
    );
  }
}

/// Akış üzerindeki tek bir gönderi kartı widget'ı.
class _FeedPostCard extends StatelessWidget {
  final FeedPost post;

  const _FeedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Bilgi: Profil fotoğrafı/baş harf, İsim, Post Türü Badge'i
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryIndigo.withValues(alpha: 0.1),
                backgroundImage: post.authorPhotoUrl != null
                    ? NetworkImage(post.authorPhotoUrl!)
                    : null,
                child: post.authorPhotoUrl == null
                    ? Text(
                        post.authorName.isNotEmpty
                            ? post.authorName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primaryIndigo,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (post.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(post.createdAt!),
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              _buildTypeBadge(post.type),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Gönderi Metni
          Text(
            post.text,
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: AppSpacing.md),

          // Alt Bilgi: Beğeni Sayısı vb.
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${post.likeCount}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(PostType type) {
    String label;
    Color color;

    switch (type) {
      case PostType.general:
        label = 'Genel';
        color = AppColors.primaryIndigo;
        break;
      case PostType.campus:
        label = 'Kampüs';
        color = AppColors.categoryCampus;
        break;
      case PostType.announcement:
        label = 'Duyuru';
        color = AppColors.accentPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

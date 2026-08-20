import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/feed_post.dart';

/// Ana akışta gösterilecek gönderi kartı bileşeni.
///
/// [FeedPost] modelini alır ve kartı oluşturur.
/// Beğeni ve rapor butonları görsel olarak bulunur ancak
/// bu issue kapsamında işlevsel değildir.
class PostCard extends StatelessWidget {
  /// Gösterilecek gönderi verisi.
  final FeedPost post;

  /// Gönderi yazarının üniversite adı (opsiyonel).
  /// Firestore'dan `universityName` alanı gelene kadar boş olabilir.
  final String? universityName;

  /// Gönderi yazarının bölüm adı (opsiyonel).
  final String? departmentName;

  const PostCard({
    super.key,
    required this.post,
    this.universityName,
    this.departmentName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Yazar Bilgisi ────────────────────────────────────
            _AuthorHeader(
              authorName: post.authorName,
              authorPhotoUrl: post.authorPhotoUrl,
              universityName: universityName,
              departmentName: departmentName,
              createdAt: post.createdAt,
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Post Metni ──────────────────────────────────────
            if (post.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  post.text,
                  style: theme.textTheme.bodyLarge,
                ),
              ),

            // ─── Post Görseli ────────────────────────────────────
            if (post.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _PostImage(imageUrl: post.imageUrls.first),
              ),

            // ─── Alt Aksiyon Çubuğu ─────────────────────────────
            _ActionBar(likeCount: post.likeCount),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alt Bileşenler
// ─────────────────────────────────────────────────────────────────────────────

/// Yazar avatarı, adı, üniversite/bölüm ve tarih bilgisini gösterir.
class _AuthorHeader extends StatelessWidget {
  final String authorName;
  final String? authorPhotoUrl;
  final String? universityName;
  final String? departmentName;
  final DateTime? createdAt;

  const _AuthorHeader({
    required this.authorName,
    this.authorPhotoUrl,
    this.universityName,
    this.departmentName,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Avatar
        _buildAvatar(),
        const SizedBox(width: AppSpacing.md),

        // Ad, üniversite/bölüm, tarih
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authorName,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_buildSubtitle().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _buildSubtitle(),
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Tarih
        if (createdAt != null)
          Text(
            _formatRelativeDate(createdAt!),
            style: theme.textTheme.labelSmall,
          ),
      ],
    );
  }

  /// Yazar profil fotoğrafı varsa NetworkImage, yoksa baş harf gösterir.
  Widget _buildAvatar() {
    final initials = authorName.isNotEmpty ? authorName[0].toUpperCase() : '?';

    if (authorPhotoUrl != null && authorPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(authorPhotoUrl!),
        backgroundColor: AppColors.border,
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryIndigo,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Üniversite ve bölüm bilgisini birleştirerek alt başlık oluşturur.
  String _buildSubtitle() {
    final uni = universityName ?? '';
    final dept = departmentName ?? '';

    if (uni.isNotEmpty && dept.isNotEmpty) {
      return '$uni · $dept';
    }
    if (uni.isNotEmpty) return uni;
    if (dept.isNotEmpty) return dept;
    return '';
  }

  /// Geçmiş tarihi okunabilir formatta döndürür (örn: "2d", "3sa", "5dk").
  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 365) {
      return '${diff.inDays ~/ 365}y';
    } else if (diff.inDays >= 30) {
      return '${diff.inDays ~/ 30}ay';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}g';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}sa';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}dk';
    } else {
      return 'Şimdi';
    }
  }
}

/// Görsel yoksa hiç alan kaplamaz, varsa yuvarlatılmış köşelerle gösterir.
class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderRadiusSm,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryIndigo,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textSecondary,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Beğeni sayısı ve rapor butonunu gösterir.
/// Butonlar görsel olarak bulunur ancak tıklama işlevi yoktur.
class _ActionBar extends StatelessWidget {
  final int likeCount;

  const _ActionBar({required this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Beğeni butonu + sayısı
        _ActionButton(
          icon: Icons.favorite_border,
          label: likeCount > 0 ? '$likeCount' : null,
          onPressed: () {
            // Beğeni tıklama bu issue kapsamında çalışmayacak.
          },
        ),

        const Spacer(),

        // Rapor butonu
        _ActionButton(
          icon: Icons.flag_outlined,
          onPressed: () {
            // Raporlama bu issue kapsamında çalışmayacak.
          },
        ),
      ],
    );
  }
}

/// Tekrar kullanılabilir aksiyon butonu (ikon + opsiyonel etiket).
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadius.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
            if (label != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/post_like_service.dart';

/// Gönderi beğeni buton widget'ı.
///
/// Gönderinin beğeni durumunu (kalp ikonu) ve toplam beğeni sayısını gösterir.
/// Tıklamada anlık (optimistic) UI güncellemesi yapar ve arka planda
/// [PostLikeService] üzerinden Firestore transaction işlemini yürütür.
class PostLikeButton extends StatefulWidget {
  /// Beğenilecek gönderinin ID'si.
  final String postId;

  /// İşlemi yapan aktif kullanıcının ID'si.
  final String userId;

  /// Başlangıç beğeni sayısı.
  final int initialLikeCount;

  /// Kullanıcının bu gönderiyi başlangıçta beğenip beğenmediği.
  final bool? initialIsLiked;

  /// Test edilebilirlik veya dışarıdan enjeksiyon için servis örneği.
  final PostLikeService? postLikeService;

  /// Beğeni durumu değiştiğinde tetiklenen opsiyonel callback.
  final void Function(bool isLiked, int newLikeCount)? onLikeChanged;

  const PostLikeButton({
    super.key,
    required this.postId,
    required this.userId,
    this.initialLikeCount = 0,
    this.initialIsLiked,
    this.postLikeService,
    this.onLikeChanged,
  });

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton> {
  late final PostLikeService _likeService;

  late bool _isLiked;
  late int _likeCount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _likeService = widget.postLikeService ?? PostLikeService();
    _isLiked = widget.initialIsLiked ?? false;
    _likeCount = widget.initialLikeCount < 0 ? 0 : widget.initialLikeCount;

    // Eğer başlangıç durumu dışarıdan verilmediyse servisten kontrol et
    if (widget.initialIsLiked == null &&
        widget.userId.isNotEmpty &&
        widget.postId.isNotEmpty) {
      _checkInitialLikeStatus();
    }
  }

  @override
  void didUpdateWidget(covariant PostLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLikeCount != widget.initialLikeCount) {
      _likeCount = widget.initialLikeCount < 0 ? 0 : widget.initialLikeCount;
    }
    if (widget.initialIsLiked != null &&
        oldWidget.initialIsLiked != widget.initialIsLiked) {
      _isLiked = widget.initialIsLiked!;
    }
  }

  Future<void> _checkInitialLikeStatus() async {
    try {
      final isLiked = await _likeService.isPostLiked(
        postId: widget.postId,
        userId: widget.userId,
      );
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    } catch (_) {
      // Başlangıç kontrolü hatası durumunda mevcut state korunur.
    }
  }

  Future<void> _handleToggleLike() async {
    if (_isLoading) return;

    if (widget.userId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beğenmek için giriş yapmalısınız.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Eski durumları sakla (hata olursa geri almak için)
    final previousIsLiked = _isLiked;
    final previousLikeCount = _likeCount;

    // Optimistic UI güncellemesi (anlık görsel tepki)
    final nextIsLiked = !_isLiked;
    final nextLikeCount =
        nextIsLiked ? _likeCount + 1 : (_likeCount > 0 ? _likeCount - 1 : 0);

    setState(() {
      _isLiked = nextIsLiked;
      _likeCount = nextLikeCount;
      _isLoading = true;
    });

    widget.onLikeChanged?.call(_isLiked, _likeCount);

    try {
      final result = await _likeService.toggleLike(
        postId: widget.postId,
        userId: widget.userId,
      );

      if (mounted) {
        setState(() {
          _isLiked = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Hata durumunda eski değerlere geri dön
      if (mounted) {
        setState(() {
          _isLiked = previousIsLiked;
          _likeCount = previousLikeCount;
          _isLoading = false;
        });

        widget.onLikeChanged?.call(_isLiked, _likeCount);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beğeni işlemi gerçekleştirilemedi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleToggleLike,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(_isLiked),
                size: 20,
                color: _isLiked ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$_likeCount',
              style: AppTextStyles.labelMedium.copyWith(
                color: _isLiked ? AppColors.error : AppColors.textSecondary,
                fontWeight: _isLiked ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

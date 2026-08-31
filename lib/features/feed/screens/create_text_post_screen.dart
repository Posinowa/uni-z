import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../profile/services/profile_service.dart';
import '../models/feed_post.dart';
import '../models/post_status.dart';
import '../models/post_type.dart';
import '../services/feed_service.dart';

/// Kullanıcının yeni metin gönderisi oluşturabileceği form ekranı.
///
/// Post türü (Genel, Kampüs, Duyuru) seçimi ve metin içeriği alır.
/// Paylaşım sırasında mevcut kullanıcının profil bilgilerini snapshot olarak
/// gönderiye ekler ve Firestore `posts` koleksiyonuna kaydeder.
class CreateTextPostScreen extends StatefulWidget {
  /// Gönderi başarıyla oluşturulduğunda çağrılacak opsiyonel geri bildirim fonksiyonu.
  /// Shell ekranında sekmeyi akışa (Feed) çevirmek için kullanılır.
  final VoidCallback? onPostCreated;

  /// Test edilebilirlik için opsiyonel servis parametreleri.
  final FeedService? feedService;
  final ProfileService? profileService;
  final FirebaseAuth? authInstance;

  const CreateTextPostScreen({
    this.onPostCreated,
    this.feedService,
    this.profileService,
    this.authInstance,
    super.key,
  });

  @override
  State<CreateTextPostScreen> createState() => _CreateTextPostScreenState();
}

class _CreateTextPostScreenState extends State<CreateTextPostScreen> {
  late final FeedService _feedService;
  late final ProfileService _profileService;
  late final FirebaseAuth _auth;

  final TextEditingController _textController = TextEditingController();

  PostType _selectedType = PostType.general;
  bool _hasText = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _feedService = widget.feedService ?? FeedService();
    _profileService = widget.profileService ?? ProfileService();
    _auth = widget.authInstance ?? FirebaseAuth.instance;

    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  /// Gönderiyi Firestore'a kaydeder.
  Future<void> _submitPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gönderi paylaşmak için giriş yapmış olmalısınız.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = currentUser.uid;

      // Kullanıcı profil bilgilerini (snapshot) getir
      final profile = await _profileService.getUserProfile(uid);

      final authorName = (profile?.fullName.trim().isNotEmpty ?? false)
          ? profile!.fullName
          : (currentUser?.displayName?.trim().isNotEmpty ?? false)
              ? currentUser!.displayName!
              : 'Öğrenci';

      final universityId = profile?.universityId ?? '';
      final departmentId = profile?.departmentId;
      final authorPhotoUrl = profile?.profileImageUrl ?? currentUser?.photoURL;

      final now = DateTime.now();
      final post = FeedPost(
        id: '',
        authorId: uid,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        universityId: universityId,
        departmentId: departmentId,
        type: _selectedType,
        text: text,
        imageUrls: const [],
        likeCount: 0,
        reportCount: 0,
        status: PostStatus.published,
        createdAt: now,
        updatedAt: now,
      );

      await _feedService.createPost(post);

      if (!mounted) return;

      _textController.clear();
      setState(() {
        _isLoading = false;
        _hasText = false;
        _selectedType = PostType.general;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gönderiniz başarıyla paylaşıldı.'),
          backgroundColor: AppColors.success,
        ),
      );

      // Başarılı kayıt sonrası akış ekranına yönlendir
      if (widget.onPostCreated != null) {
        widget.onPostCreated!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      debugPrint('Gönderi paylaşma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gönderi paylaşılırken bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Gönderi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Post Türü Seçici
              _buildTypeSelector(),

              const SizedBox(height: AppSpacing.xl),

              // Metin Giriş Alanı
              AppTextField(
                hint: 'Ne düşünüyorsun?',
                controller: _textController,
                maxLines: 6,
                enabled: !_isLoading,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Paylaş Butonu
              PrimaryButton(
                text: 'Paylaş',
                isLoading: _isLoading,
                isDisabled: !_hasText || _isLoading,
                onPressed: (_hasText && !_isLoading) ? _submitPost : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post Türü',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: PostType.values.map((type) {
            final isSelected = type == _selectedType;
            return ChoiceChip(
              label: Text(_labelForType(type)),
              selected: isSelected,
              onSelected: _isLoading
                  ? null
                  : (selected) {
                      if (selected) {
                        setState(() => _selectedType = type);
                      }
                    },
              selectedColor: AppColors.primaryIndigo,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryIndigo
                      : AppColors.border,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _labelForType(PostType type) {
    switch (type) {
      case PostType.general:
        return 'Genel';
      case PostType.campus:
        return 'Kampüs';
      case PostType.announcement:
        return 'Duyuru';
    }
  }
}

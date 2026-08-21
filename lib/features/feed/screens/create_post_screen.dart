import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/mock_storage_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/feed_post.dart';
import '../models/post_status.dart';
import '../models/post_type.dart';
import '../services/feed_service.dart';

/// Post oluşturma ekranı.
///
/// Kullanıcı metin ve/veya görsel ile post paylaşabilir.
/// Görsel seçildiğinde [StorageService.uploadFile] çağrısı simüle edilir
/// ve dönen mock URL, Firestore post kaydının [imageUrls] alanına yazılır.
///
/// Bu ekran geçici olarak [MockStorageService] kullanır.
/// Gerçek R2 upload entegrasyonu hazır olduğunda servis değiştirilecektir.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  final _feedService = FeedService();
  final StorageService _storageService = MockStorageService();

  /// Seçilen görselin mock URL'i. null ise görsel seçilmemiş.
  String? _selectedImageMockUrl;

  /// Görsel seçim simülasyonu yapıldı mı?
  bool _hasSelectedImage = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Görsel seçimini simüle eder.
  ///
  /// Gerçek dosya seçici (image_picker) yerine mock bir dosya oluşturur
  /// ve [MockStorageService.uploadFile] ile sahte URL alır.
  Future<void> _simulateImagePick() async {
    setState(() => _isLoading = true);

    try {
      // Mock dosya yolu — gerçek dosya seçici olmadan simülasyon
      final mockFile = File('mock_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final mockFileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // StorageService.uploadFile çağrısını simüle et
      final mockUrl = await _storageService.uploadFile(
        file: mockFile,
        folder: 'post_images',
        fileName: mockFileName,
      );

      setState(() {
        _selectedImageMockUrl = mockUrl;
        _hasSelectedImage = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel seçilirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Seçilen görseli kaldırır.
  void _removeImage() {
    setState(() {
      _selectedImageMockUrl = null;
      _hasSelectedImage = false;
    });
  }

  /// Post'u oluşturup Firestore'a kaydeder.
  Future<void> _submitPost() async {
    final text = _textController.text.trim();

    // En az metin veya görsel olmalı
    if (text.isEmpty && !_hasSelectedImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir metin girin veya görsel ekleyin.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı giriş yapmamış.');
      }

      // imageUrls listesini oluştur
      final imageUrls = <String>[];
      if (_selectedImageMockUrl != null) {
        imageUrls.add(_selectedImageMockUrl!);
      }

      final post = FeedPost(
        id: '', // FeedService tarafından set edilecek
        authorId: currentUser.uid,
        authorName: currentUser.displayName ?? 'Anonim',
        authorPhotoUrl: currentUser.photoURL,
        universityId: '', // TODO: Profil tamamlandığında kullanıcı bilgisinden alınacak
        type: PostType.general,
        text: text,
        imageUrls: imageUrls,
        status: PostStatus.published,
      );

      await _feedService.createPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post paylaşıldı!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post paylaşılırken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Post'),
        actions: [
          // Paylaş butonu
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton(
              onPressed: _isLoading ? null : _submitPost,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Paylaş',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primaryIndigo,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Metin giriş alanı
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Ne paylaşmak istiyorsun?',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                  ),
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            ),

            // Seçilen görsel önizleme
            if (_hasSelectedImage) _buildImagePreview(),

            // Alt araç çubuğu
            _buildBottomToolbar(),
          ],
        ),
      ),
    );
  }

  /// Seçilen görselin önizlemesini gösterir.
  ///
  /// Mock upload olduğu için gerçek görsel yerine
  /// placeholder bir kart gösterilir.
  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image,
                  size: 48,
                  color: AppColors.primaryIndigo,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Görsel eklendi (mock)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _selectedImageMockUrl ?? '',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Kaldır butonu
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Alt araç çubuğu — görsel ekleme butonu.
  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoading || _hasSelectedImage
                ? null
                : _simulateImagePick,
            icon: Icon(
              Icons.image_outlined,
              color: _hasSelectedImage
                  ? AppColors.textSecondary
                  : AppColors.primaryIndigo,
            ),
            tooltip: 'Görsel ekle',
          ),
          if (_hasSelectedImage)
            Text(
              '1 görsel seçildi',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:uniz_mobile/core/services/storage_service.dart';

/// Test ve geliştirme için geçici mock storage servisi.
///
/// Gerçek R2 upload yerine dosyanın local path'ini döndürür.
/// Bu sınıf sadece geliştirme/test aşamasında kullanılmalıdır.
///
/// Gerçek upload entegrasyonu hazır olduğunda bu sınıf
/// [R2StorageService] ile değiştirilecektir.
class MockStorageService extends StorageService {
  /// Sahte bir upload simülasyonu yapar.
  ///
  /// Gerçek dosya yüklemesi yapmaz. Kısa bir bekleme sonrası
  /// dosyanın local path'ini döndürür; böylece [PostCard] görseli
  /// [Image.file] ile anında render edebilir.
  @override
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  }) async {
    // Gerçek upload'u simüle etmek için kısa bekleme
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Local path döndür — PostCard Image.file() ile render eder
    return file.path;
  }

  @override
  Future<void> deleteFile({
    required String fileKey,
  }) async {
    // Mock delete — gerçek silme işlemi yapmaz
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

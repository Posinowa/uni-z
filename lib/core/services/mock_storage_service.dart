import 'dart:io';

import 'package:uniz_mobile/core/services/storage_service.dart';

/// Test ve geliştirme için geçici mock storage servisi.
///
/// Gerçek R2 upload yerine sahte bir URL döndürür.
/// Bu sınıf sadece geliştirme/test aşamasında kullanılmalıdır.
///
/// Gerçek upload entegrasyonu hazır olduğunda bu sınıf
/// [R2StorageService] ile değiştirilecektir.
class MockStorageService extends StorageService {
  /// Sahte bir upload simülasyonu yapar.
  ///
  /// Gerçek dosya yüklemesi yapmaz. Kısa bir bekleme sonrası
  /// mock bir URL döndürür.
  @override
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  }) async {
    // Gerçek upload'u simüle etmek için kısa bekleme
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock URL döndür — gerçek R2 URL formatına benzer
    return 'https://mock-r2.uniz.dev/$folder/$fileName';
  }

  @override
  Future<void> deleteFile({
    required String fileKey,
  }) async {
    // Mock delete — gerçek silme işlemi yapmaz
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

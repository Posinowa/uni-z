import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/report_model.dart';

/// Firestore `reports` koleksiyonu üzerindeki rapor oluşturma ve
/// duplicate kontrol işlemlerini yöneten servis sınıfı.
///
/// Kapsam dışı: Admin rapor yönetimi ve rapor listeleme.
/// Hata durumlarında Firestore istisnaları üst katmana fırlatılır.
class ReportService extends FirestoreService {
  /// [ReportService] oluşturur.
  ///
  /// Test edilebilirlik için opsiyonel [firestoreInstance] kabul eder.
  ReportService({super.firestoreInstance})
      : super(FirestoreCollections.reports);

  /// Yeni bir raporu Firestore `reports` koleksiyonuna kaydeder.
  ///
  /// - [report] nesnesinin `id` alanı Firestore tarafından otomatik atanır;
  ///   bu nedenle boş string (`''`) geçilmelidir.
  /// - Aynı kullanıcı aynı içeriği zaten raporlamışsa [StateError] fırlatır.
  /// - İşlem sırasında hata oluşursa [FirebaseException] fırlatır.
  Future<void> createReport(ReportModel report) async {
    // Tekrar raporlamayı önlemek için önce duplicate kontrolü yapılır.
    final alreadyReported = await hasUserReported(
      targetType: report.targetType.value,
      targetId: report.targetId,
      userId: report.reportedBy,
    );

    if (alreadyReported) {
      throw StateError(
        'Bu içerik zaten raporlandı. Aynı içerik tekrar raporlanamaz.',
      );
    }

    final docRef = collection.doc();
    final reportWithId = report.copyWith(
      id: docRef.id,
      createdAt: report.createdAt ?? DateTime.now(),
    );
    await docRef.set(reportWithId.toMap());
  }

  /// Belirtilen kullanıcının ilgili içeriği daha önce raporlayıp
  /// raporlamadığını kontrol eder.
  ///
  /// - [targetType] içerik türü (örn. `'post'`, `'material'`, `'event'`, `'user'`).
  /// - [targetId] raporlanan içeriğin Firestore belge kimliği.
  /// - [userId] raporu oluşturan kullanıcının kimliği.
  /// - Herhangi bir parametre boşsa `false` döner.
  /// - İşlem sırasında hata oluşursa [FirebaseException] fırlatır.
  Future<bool> hasUserReported({
    required String targetType,
    required String targetId,
    required String userId,
  }) async {
    if (targetType.trim().isEmpty ||
        targetId.trim().isEmpty ||
        userId.trim().isEmpty) {
      return false;
    }

    final querySnapshot = await collection
        .where('targetType', isEqualTo: targetType)
        .where('targetId', isEqualTo: targetId)
        .where('reportedBy', isEqualTo: userId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}

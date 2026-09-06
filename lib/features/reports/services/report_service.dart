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
  /// Deterministic doc ID kullanır: `{userId}_{targetType}_{targetId}`.
  /// Bu sayede aynı kullanıcı-hedef çifti için concurrent isteklerde bile
  /// tek kayıt oluşur (idempotent).
  ///
  /// - [report.reportedBy] veya [report.targetId] boşsa [ArgumentError] fırlatır.
  /// - Aynı kullanıcı aynı içeriği zaten raporlamışsa [StateError] fırlatır.
  /// - İşlem sırasında hata oluşursa [FirebaseException] fırlatır.
  Future<void> createReport(ReportModel report) async {
    // Auth guard: oturumsuz veya eksik veriyle rapor oluşturulamaz.
    if (report.reportedBy.trim().isEmpty) {
      throw ArgumentError('reportedBy boş olamaz. Kullanıcı giriş yapmış olmalıdır.');
    }
    if (report.targetId.trim().isEmpty) {
      throw ArgumentError('targetId boş olamaz.');
    }
    if (report.reason.trim().isEmpty) {
      throw ArgumentError('reason boş olamaz.');
    }

    final docId = _buildDocId(
      userId: report.reportedBy,
      targetType: report.targetType.value,
      targetId: report.targetId,
    );

    // Aynı kullanıcı-hedef çifti daha önce raporlanmış mı kontrol et.
    final existingDoc = await collection.doc(docId).get();
    if (existingDoc.exists) {
      throw StateError(
        'Bu içerik zaten raporlandı. Aynı içerik tekrar raporlanamaz.',
      );
    }

    final reportToSave = report.createdAt == null
        ? report.copyWith(createdAt: DateTime.now())
        : report;

    // Deterministic ID ile set — concurrent isteklerde idempotent.
    await collection.doc(docId).set(reportToSave.toMap());
  }

  /// Belirtilen kullanıcının ilgili içeriği daha önce raporlayıp
  /// raporlamadığını kontrol eder.
  ///
  /// Deterministic doc ID ile tek document okuma yapar.
  /// Herhangi bir parametre boşsa `false` döner.
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

    final docId = _buildDocId(
      userId: userId,
      targetType: targetType,
      targetId: targetId,
    );

    final doc = await collection.doc(docId).get();
    return doc.exists;
  }

  /// Deterministic rapor belgesi kimliği oluşturur.
  ///
  /// Format: `{userId}_{targetType}_{targetId}`
  /// Bu sayede aynı kullanıcı-hedef çifti için her zaman aynı ID üretilir.
  String _buildDocId({
    required String userId,
    required String targetType,
    required String targetId,
  }) {
    return '${userId}_${targetType}_$targetId';
  }
}

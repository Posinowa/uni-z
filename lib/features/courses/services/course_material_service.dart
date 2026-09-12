import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';

/// Ders materyali işlemlerini yöneten servis sınıfı.
///
/// Yüklenen materyal, `status: pending` olarak Firestore
/// `courseMaterials` koleksiyonuna kaydedilir.
/// Admin onaylamadan önce materyal listesinde görünmez.
class CourseMaterialService {
  final FirebaseFirestore _firestore;

  CourseMaterialService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Belirtilen derse ait, admin tarafından onaylanmış materyalleri
  /// gerçek zamanlı olarak dinleyen stream döner.
  ///
  /// Sadece `status: approved` olan belgeler döner.
  /// Sonuçlar yüklenme tarihine göre yeniden eskiye sıralanır.
  ///
  /// [courseId]: Materyalleri listelenecek dersin Firestore ID'si.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedMaterials(
    String courseId,
  ) {
    return _firestore
        .collection(FirestoreCollections.courseMaterials)
        .where('courseId', isEqualTo: courseId)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Yeni ders materyalini Firestore'a pending olarak kaydeder.
  ///
  /// [courseId]: Materyalin ait olduğu ders ID'si.
  /// [uploadedBy]: Yükleyen kullanıcının UID'si.
  /// [title]: Materyal başlığı.
  /// [description]: Opsiyonel açıklama.
  /// [type]: Materyal tipi (lecture_note, past_exam, summary, other).
  /// [fileUrl]: Mock veya gerçek dosya URL'i.
  /// [fileKey]: Storage'daki dosya anahtarı.
  /// [fileType]: Dosya uzantısı (pdf, jpg vb.).
  /// [fileSize]: Dosya boyutu (byte).
  ///
  /// Firestore'a kaydedilen belge şeması (PROJECT_CONTEXT.md §15.7):
  /// ```json
  /// {
  ///   "courseId": "...",
  ///   "title": "...",
  ///   "description": "...",
  ///   "type": "lecture_note",
  ///   "fileUrl": "https://mock-r2.uniz.dev/...",
  ///   "fileKey": "course_materials/...",
  ///   "fileType": "pdf",
  ///   "fileSize": 102400,
  ///   "status": "pending",
  ///   "uploadedBy": "<userId>",
  ///   "reportCount": 0,
  ///   "createdAt": <Timestamp>,
  ///   "approvedBy": null,
  ///   "approvedAt": null
  /// }
  /// ```
  Future<void> saveMaterial({
    required String courseId,
    required String uploadedBy,
    required String title,
    String? description,
    required String type,
    required String fileUrl,
    required String fileKey,
    required String fileType,
    required int fileSize,
  }) async {
    await _firestore.collection(FirestoreCollections.courseMaterials).add({
      'courseId': courseId,
      'uploadedBy': uploadedBy,
      'title': title.trim(),
      'description': description?.trim() ?? '',
      'type': type,
      'fileUrl': fileUrl,
      'fileKey': fileKey,
      'fileType': fileType,
      'fileSize': fileSize,
      'status': 'pending',
      'reportCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'approvedBy': null,
      'approvedAt': null,
    });
  }
}

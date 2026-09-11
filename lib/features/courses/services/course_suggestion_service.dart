import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';

/// Ders önerisi gönderme işlemlerini yöneten servis sınıfı.
///
/// Kullanıcıdan gelen ders önerisi, `status: pending` olarak
/// Firestore `courses` koleksiyonuna kaydedilir.
/// Admin onaylamadan önce listede görünmez.
class CourseSuggestionService {
  final FirebaseFirestore _firestore;

  CourseSuggestionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Yeni ders önerisini Firestore'a kaydeder.
  ///
  /// [userId]: Öneriyi gönderen kullanıcının UID'si.
  /// [courseCode]: Ders kodu (örn. "CS101").
  /// [courseName]: Ders adı (örn. "Veri Yapıları").
  /// [department]: Bölüm adı (örn. "Bilgisayar Mühendisliği").
  /// [description]: Opsiyonel açıklama metni.
  ///
  /// Firestore'a kaydedilen belge şeması:
  /// ```json
  /// {
  ///   "courseCode": "CS101",
  ///   "courseName": "Veri Yapıları",
  ///   "department": "Bilgisayar Mühendisliği",
  ///   "description": "...",
  ///   "status": "pending",
  ///   "createdBy": "<userId>",
  ///   "createdAt": <Timestamp>
  /// }
  /// ```
  Future<void> suggestCourse({
    required String userId,
    required String courseCode,
    required String courseName,
    required String department,
    String? description,
  }) async {
    await _firestore.collection(FirestoreCollections.courses).add({
      'courseCode': courseCode.trim(),
      'courseName': courseName.trim(),
      'department': department.trim(),
      'description': description?.trim() ?? '',
      'status': 'pending',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

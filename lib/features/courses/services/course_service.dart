import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/course_model.dart';
import '../models/course_status.dart';

/// Firestore `courses` koleksiyonu üzerindeki ders işlemlerini yöneten servis sınıfı.
///
/// UI bağımlılığı içermez.
/// Kapsam dışı: Admin onaylama/reddetme işlemleri ve ders materyalleri yönetimi.
class CourseService extends FirestoreService {
  /// [CourseService] oluşturur.
  ///
  /// Testlerde mock instance enjekte edebilmek için opsiyonel [firestoreInstance] kabul eder.
  CourseService({super.firestoreInstance})
      : super(FirestoreCollections.courses);

  /// Onaylanmış (`status == approved`) dersleri gerçek zamanlı (Stream) olarak dinler.
  ///
  /// - [universityId]: Zorunlu üniversite ID'si filtresi.
  /// - [departmentId]: Opsiyonel bölüm ID'si filtresi. Belirtilirse sadece o bölüme ait dersleri getirir.
  Stream<List<CourseModel>> watchApprovedCourses({
    required String universityId,
    String? departmentId,
  }) {
    Query<Map<String, dynamic>> query = collection
        .where('universityId', isEqualTo: universityId)
        .where('status', isEqualTo: CourseStatus.approved.value);

    if (departmentId != null && departmentId.trim().isNotEmpty) {
      query = query.where('departmentId', isEqualTo: departmentId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Yeni bir ders ekleme talebini Firestore `courses` koleksiyonuna kaydeder.
  ///
  /// Kabul kriteri gereğince, ders her zaman [CourseStatus.pending] durumunda kaydedilir.
  /// Belge ID'si boşsa Firestore tarafından otomatik yeni bir ID atanır.
  Future<void> createPendingCourse(CourseModel course) async {
    final docRef =
        course.id.trim().isEmpty ? collection.doc() : collection.doc(course.id);

    final pendingCourse = course.copyWith(
      id: docRef.id,
      status: CourseStatus.pending,
      approvedBy: null,
      approvedAt: null,
    );

    final createdAt = course.createdAt != null
        ? Timestamp.fromDate(course.createdAt!)
        : FieldValue.serverTimestamp();

    final courseData = pendingCourse.toMap()
      ..['id'] = docRef.id
      ..['createdAt'] = createdAt;

    await docRef.set(courseData);
  }

  /// Belirtilen [courseId] kimliğine sahip dersi Firestore'dan çeker.
  ///
  /// Belge bulunamazsa veya [courseId] boşsa `null` döner.
  Future<CourseModel?> getCourseById(String courseId) async {
    if (courseId.trim().isEmpty) {
      return null;
    }

    final docSnapshot = await collection.doc(courseId).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return null;
    }

    return CourseModel.fromMap(docSnapshot.data()!, id: docSnapshot.id);
  }
}

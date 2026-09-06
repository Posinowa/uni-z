import 'package:cloud_firestore/cloud_firestore.dart';

import 'course_status.dart';

const Object _sentinel = Object();

/// Firestore `courses` koleksiyonu için model sınıfı.
///
/// PROJECT_CONTEXT.md Bölüm 15.6'daki veri modeline uygun olarak tasarlanmıştır.
///
/// Alanlar:
/// - [id]: Firestore belge ID'si.
/// - [universityId], [departmentId]: Dersin bağlı olduğu üniversite ve bölüm.
/// - [courseCode]: Dersin kodu (örn. "CS101").
/// - [courseName]: Dersin adı (örn. "Veri Yapıları").
/// - [description]: Opsiyonel açıklama.
/// - [status]: Admin onay durumu ([CourseStatus]).
/// - [createdBy]: Talebi oluşturan kullanıcının UID'si.
/// - [createdAt]: Talep oluşturulma zamanı.
/// - [approvedBy]: Onaylayan admin'in UID'si (nullable).
/// - [approvedAt]: Onaylanma zamanı (nullable).
class Course {
  final String id;
  final String universityId;
  final String departmentId;
  final String courseCode;
  final String courseName;
  final String? description;
  final CourseStatus status;
  final String createdBy;
  final DateTime? createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;

  const Course({
    required this.id,
    required this.universityId,
    required this.departmentId,
    required this.courseCode,
    required this.courseName,
    this.description,
    this.status = CourseStatus.pending,
    required this.createdBy,
    this.createdAt,
    this.approvedBy,
    this.approvedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [Course] oluşturur.
  factory Course.fromMap(Map<String, dynamic> map, {String? id}) {
    return Course(
      id: id ?? map['id'] as String? ?? '',
      universityId: map['universityId'] as String? ?? '',
      departmentId: map['departmentId'] as String? ?? '',
      courseCode: map['courseCode'] as String? ?? '',
      courseName: map['courseName'] as String? ?? '',
      description: map['description'] as String?,
      status: CourseStatus.fromString(map['status'] as String?),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      approvedBy: map['approvedBy'] as String?,
      approvedAt: _parseDateTime(map['approvedAt']),
    );
  }

  /// [Course] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'universityId': universityId,
      'departmentId': departmentId,
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'status': status.value,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  ///
  /// Nullable alanlar ([description], [approvedBy], [approvedAt])
  /// açıkça `null` geçilerek temizlenebilir.
  Course copyWith({
    String? id,
    String? universityId,
    String? departmentId,
    String? courseCode,
    String? courseName,
    Object? description = _sentinel,
    CourseStatus? status,
    String? createdBy,
    DateTime? createdAt,
    Object? approvedBy = _sentinel,
    Object? approvedAt = _sentinel,
  }) {
    return Course(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      departmentId: departmentId ?? this.departmentId,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      description: identical(description, _sentinel)
          ? this.description
          : (description as String?),
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      approvedBy: identical(approvedBy, _sentinel)
          ? this.approvedBy
          : (approvedBy as String?),
      approvedAt: identical(approvedAt, _sentinel)
          ? this.approvedAt
          : (approvedAt as DateTime?),
    );
  }

  /// Farklı tiplerdeki tarih verilerini (Timestamp, DateTime, String, int)
  /// güvenli bir şekilde [DateTime] nesnesine ayrıştırır.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

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
/// - [universityName], [departmentName]: Üniversite ve bölüm adları (opsiyonel).
/// - [courseCode]: Dersin kodu (örn. "CS101").
/// - [courseName]: Dersin adı (örn. "Veri Yapıları").
/// - [description]: Opsiyonel açıklama.
/// - [status]: Admin onay durumu ([CourseStatus]).
/// - [createdBy]: Talebi oluşturan kullanıcının UID'si.
/// - [createdAt]: Talep oluşturulma zamanı.
/// - [approvedBy]: Onaylayan admin'in UID'si (nullable).
/// - [approvedAt]: Onaylanma zamanı (nullable).
class CourseModel {
  final String id;
  final String universityId;
  final String? universityName;
  final String departmentId;
  final String? departmentName;
  final String courseCode;
  final String courseName;
  final String? description;
  final CourseStatus status;
  final String createdBy;
  final DateTime? createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;

  const CourseModel({
    required this.id,
    required this.universityId,
    this.universityName,
    required this.departmentId,
    this.departmentName,
    required this.courseCode,
    required this.courseName,
    this.description,
    this.status = CourseStatus.pending,
    required this.createdBy,
    this.createdAt,
    this.approvedBy,
    this.approvedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [CourseModel] oluşturur.
  factory CourseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CourseModel(
      id: id ?? map['id'] as String? ?? '',
      universityId: map['universityId'] as String? ?? '',
      universityName: map['universityName'] as String?,
      departmentId: map['departmentId'] as String? ?? '',
      departmentName: map['departmentName'] as String?,
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

  /// [CourseModel] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'universityId': universityId,
      if (universityName != null) 'universityName': universityName,
      'departmentId': departmentId,
      if (departmentName != null) 'departmentName': departmentName,
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
  /// Nullable alanlar ([description], [universityName], [departmentName],
  /// [approvedBy], [approvedAt]) açıkça `null` geçilerek temizlenebilir.
  CourseModel copyWith({
    String? id,
    String? universityId,
    Object? universityName = _sentinel,
    String? departmentId,
    Object? departmentName = _sentinel,
    String? courseCode,
    String? courseName,
    Object? description = _sentinel,
    CourseStatus? status,
    String? createdBy,
    DateTime? createdAt,
    Object? approvedBy = _sentinel,
    Object? approvedAt = _sentinel,
  }) {
    return CourseModel(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      universityName: identical(universityName, _sentinel)
          ? this.universityName
          : (universityName as String?),
      departmentId: departmentId ?? this.departmentId,
      departmentName: identical(departmentName, _sentinel)
          ? this.departmentName
          : (departmentName as String?),
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

/// Geriye dönük uyumluluk ve alternatif adlandırma için tip tanımı.
typedef Course = CourseModel;

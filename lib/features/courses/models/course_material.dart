import 'package:cloud_firestore/cloud_firestore.dart';

import 'material_status.dart';
import 'material_type.dart';

const Object _sentinel = Object();

/// Firestore `courseMaterials` koleksiyonu için model sınıfı.
///
/// PROJECT_CONTEXT.md Bölüm 15.7'deki veri modeline uygun olarak tasarlanmıştır.
///
/// Alanlar:
/// - [id]: Firestore belge ID'si.
/// - [courseId]: Materyalin bağlı olduğu ders.
/// - [universityId], [departmentId]: Üniversite ve bölüm bilgisi.
/// - [uploadedBy]: Yükleyen kullanıcının UID'si.
/// - [title]: Materyal başlığı.
/// - [description]: Opsiyonel açıklama.
/// - [type]: Materyal türü ([MaterialType]).
/// - [fileUrl]: Cloudflare R2'deki dosyanın URL'si.
/// - [fileKey]: Cloudflare R2'deki dosya anahtarı.
/// - [fileType]: Dosya MIME tipi (örn. "application/pdf").
/// - [fileSize]: Dosya boyutu (byte).
/// - [status]: Admin onay durumu ([MaterialStatus]).
/// - [reportCount]: Raporlanma sayısı.
/// - [createdAt]: Yüklenme zamanı.
/// - [approvedBy]: Onaylayan admin'in UID'si (nullable).
/// - [approvedAt]: Onaylanma zamanı (nullable).
class CourseMaterial {
  final String id;
  final String courseId;
  final String universityId;
  final String departmentId;
  final String uploadedBy;
  final String title;
  final String? description;
  final MaterialType type;
  final String fileUrl;
  final String fileKey;
  final String fileType;
  final int fileSize;
  final MaterialStatus status;
  final int reportCount;
  final DateTime? createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;

  const CourseMaterial({
    required this.id,
    required this.courseId,
    required this.universityId,
    required this.departmentId,
    required this.uploadedBy,
    required this.title,
    this.description,
    this.type = MaterialType.other,
    required this.fileUrl,
    required this.fileKey,
    required this.fileType,
    this.fileSize = 0,
    this.status = MaterialStatus.pending,
    this.reportCount = 0,
    this.createdAt,
    this.approvedBy,
    this.approvedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [CourseMaterial] oluşturur.
  factory CourseMaterial.fromMap(Map<String, dynamic> map, {String? id}) {
    return CourseMaterial(
      id: id ?? map['id'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      universityId: map['universityId'] as String? ?? '',
      departmentId: map['departmentId'] as String? ?? '',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      type: MaterialType.fromString(map['type'] as String?),
      fileUrl: map['fileUrl'] as String? ?? '',
      fileKey: map['fileKey'] as String? ?? '',
      fileType: map['fileType'] as String? ?? '',
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      status: MaterialStatus.fromString(map['status'] as String?),
      reportCount: (map['reportCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      approvedBy: map['approvedBy'] as String?,
      approvedAt: _parseDateTime(map['approvedAt']),
    );
  }

  /// [CourseMaterial] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'universityId': universityId,
      'departmentId': departmentId,
      'uploadedBy': uploadedBy,
      'title': title,
      'description': description,
      'type': type.value,
      'fileUrl': fileUrl,
      'fileKey': fileKey,
      'fileType': fileType,
      'fileSize': fileSize,
      'status': status.value,
      'reportCount': reportCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  ///
  /// Nullable alanlar ([description], [approvedBy], [approvedAt])
  /// açıkça `null` geçilerek temizlenebilir.
  CourseMaterial copyWith({
    String? id,
    String? courseId,
    String? universityId,
    String? departmentId,
    String? uploadedBy,
    String? title,
    Object? description = _sentinel,
    MaterialType? type,
    String? fileUrl,
    String? fileKey,
    String? fileType,
    int? fileSize,
    MaterialStatus? status,
    int? reportCount,
    DateTime? createdAt,
    Object? approvedBy = _sentinel,
    Object? approvedAt = _sentinel,
  }) {
    return CourseMaterial(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      universityId: universityId ?? this.universityId,
      departmentId: departmentId ?? this.departmentId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      title: title ?? this.title,
      description: identical(description, _sentinel)
          ? this.description
          : (description as String?),
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileKey: fileKey ?? this.fileKey,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      reportCount: reportCount ?? this.reportCount,
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

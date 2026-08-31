import 'package:cloud_firestore/cloud_firestore.dart';

import 'report_status.dart';
import 'report_target_type.dart';

const Object _sentinel = Object();

/// Firestore `reports` koleksiyonu için model sınıfı.
class ReportModel {
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reportedBy;
  final String reason;
  final String? description;
  final ReportStatus status;
  final DateTime? createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const ReportModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reportedBy,
    required this.reason,
    this.description,
    this.status = ReportStatus.open,
    this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [ReportModel] oluşturur.
  factory ReportModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReportModel(
      id: id ?? map['id'] as String? ?? '',
      targetType: ReportTargetType.fromString(map['targetType'] as String?),
      targetId: map['targetId'] as String? ?? '',
      reportedBy: map['reportedBy'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      description: map['description'] as String?,
      status: ReportStatus.fromString(map['status'] as String?),
      createdAt: _parseDateTime(map['createdAt']),
      reviewedBy: map['reviewedBy'] as String?,
      reviewedAt: _parseDateTime(map['reviewedAt']),
    );
  }

  /// [ReportModel] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetType': targetType.value,
      'targetId': targetId,
      'reportedBy': reportedBy,
      'reason': reason,
      'description': description,
      'status': status.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'reviewedBy': reviewedBy,
      'reviewedAt':
          reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  ///
  /// Nullable alanlar ([description], [reviewedBy], [reviewedAt]) açıkça `null` geçilerek temizlenebilir.
  ReportModel copyWith({
    String? id,
    ReportTargetType? targetType,
    String? targetId,
    String? reportedBy,
    String? reason,
    Object? description = _sentinel,
    ReportStatus? status,
    DateTime? createdAt,
    Object? reviewedBy = _sentinel,
    Object? reviewedAt = _sentinel,
  }) {
    return ReportModel(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reportedBy: reportedBy ?? this.reportedBy,
      reason: reason ?? this.reason,
      description: identical(description, _sentinel)
          ? this.description
          : (description as String?),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedBy: identical(reviewedBy, _sentinel)
          ? this.reviewedBy
          : (reviewedBy as String?),
      reviewedAt: identical(reviewedAt, _sentinel)
          ? this.reviewedAt
          : (reviewedAt as DateTime?),
    );
  }

  /// Farklı tiplerdeki tarih verilerini (Timestamp, DateTime, String, int) güvenli bir şekilde [DateTime] nesnesine ayrıştırır.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `departments` koleksiyonu için model sınıfı.
class DepartmentModel {
  final String id;
  final String universityId;
  final String name;
  final bool isApproved;
  final String createdBy;
  final DateTime? createdAt;

  const DepartmentModel({
    required this.id,
    required this.universityId,
    required this.name,
    this.isApproved = false,
    required this.createdBy,
    this.createdAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [DepartmentModel] oluşturur.
  factory DepartmentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DepartmentModel(
      id: id ?? map['id'] as String? ?? '',
      universityId: map['universityId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      isApproved: map['isApproved'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// [DepartmentModel] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'universityId': universityId,
      'name': name,
      'isApproved': isApproved,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  DepartmentModel copyWith({
    String? id,
    String? universityId,
    String? name,
    bool? isApproved,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      name: name ?? this.name,
      isApproved: isApproved ?? this.isApproved,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
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

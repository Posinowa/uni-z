import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_status.dart';

const Object _sentinel = Object();

/// Firestore `events` koleksiyonu için model sınıfı.
class EventModel {
  final String id;
  final String title;
  final String description;
  final String universityId;
  final String location;
  final DateTime eventDate;
  final String? imageUrl;
  final String createdBy;
  final String organizerName;
  final EventStatus status;
  final DateTime? createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.universityId,
    required this.location,
    required this.eventDate,
    this.imageUrl,
    required this.createdBy,
    required this.organizerName,
    this.status = EventStatus.pending,
    this.createdAt,
    this.approvedBy,
    this.approvedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [EventModel] oluşturur.
  factory EventModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return EventModel(
      id: id ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      universityId: map['universityId'] as String? ?? '',
      location: map['location'] as String? ?? '',
      eventDate: _parseDateTime(map['eventDate']) ?? DateTime.now(),
      imageUrl: map['imageUrl'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      organizerName: map['organizerName'] as String? ?? '',
      status: EventStatus.fromString(map['status'] as String?),
      createdAt: _parseDateTime(map['createdAt']),
      approvedBy: map['approvedBy'] as String?,
      approvedAt: _parseDateTime(map['approvedAt']),
    );
  }

  /// [EventModel] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'universityId': universityId,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'organizerName': organizerName,
      'status': status.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  ///
  /// Nullable alanlar ([imageUrl], [approvedBy], [approvedAt]) açıkça `null` geçilerek temizlenebilir.
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? universityId,
    String? location,
    DateTime? eventDate,
    Object? imageUrl = _sentinel,
    String? createdBy,
    String? organizerName,
    EventStatus? status,
    DateTime? createdAt,
    Object? approvedBy = _sentinel,
    Object? approvedAt = _sentinel,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      universityId: universityId ?? this.universityId,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      imageUrl: identical(imageUrl, _sentinel)
          ? this.imageUrl
          : (imageUrl as String?),
      createdBy: createdBy ?? this.createdBy,
      organizerName: organizerName ?? this.organizerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedBy: identical(approvedBy, _sentinel)
          ? this.approvedBy
          : (approvedBy as String?),
      approvedAt: identical(approvedAt, _sentinel)
          ? this.approvedAt
          : (approvedAt as DateTime?),
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

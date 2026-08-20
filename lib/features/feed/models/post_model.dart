import 'package:cloud_firestore/cloud_firestore.dart';

import 'post_status.dart';
import 'post_type.dart';

const Object _sentinel = Object();

/// Firestore `posts` koleksiyonu için model sınıfı.
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String universityId;
  final String universityName;
  final String? departmentId;
  final String? departmentName;
  final PostType type;
  final String text;
  final List<String> imageUrls;
  final int likeCount;
  final int reportCount;
  final PostStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.universityId,
    required this.universityName,
    this.departmentId,
    this.departmentName,
    this.type = PostType.general,
    this.text = '',
    this.imageUrls = const [],
    this.likeCount = 0,
    this.reportCount = 0,
    this.status = PostStatus.published,
    this.createdAt,
    this.updatedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [PostModel] oluşturur.
  factory PostModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PostModel(
      id: id ?? map['id'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorPhotoUrl: map['authorPhotoUrl'] as String?,
      universityId: map['universityId'] as String? ?? '',
      universityName: map['universityName'] as String? ?? '',
      departmentId: map['departmentId'] as String?,
      departmentName: map['departmentName'] as String?,
      type: PostType.fromString(map['type'] as String?),
      text: map['text'] as String? ?? '',
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      likeCount: (map['likeCount'] as num?)?.toInt() ?? 0,
      reportCount: (map['reportCount'] as num?)?.toInt() ?? 0,
      status: PostStatus.fromString(map['status'] as String?),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  /// [PostModel] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'universityId': universityId,
      'universityName': universityName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'type': type.value,
      'text': text,
      'imageUrls': imageUrls,
      'likeCount': likeCount,
      'reportCount': reportCount,
      'status': status.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    Object? authorPhotoUrl = _sentinel,
    String? universityId,
    String? universityName,
    Object? departmentId = _sentinel,
    Object? departmentName = _sentinel,
    PostType? type,
    String? text,
    List<String>? imageUrls,
    int? likeCount,
    int? reportCount,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: identical(authorPhotoUrl, _sentinel)
          ? this.authorPhotoUrl
          : (authorPhotoUrl as String?),
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      departmentId: identical(departmentId, _sentinel)
          ? this.departmentId
          : (departmentId as String?),
      departmentName: identical(departmentName, _sentinel)
          ? this.departmentName
          : (departmentName as String?),
      type: type ?? this.type,
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      likeCount: likeCount ?? this.likeCount,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

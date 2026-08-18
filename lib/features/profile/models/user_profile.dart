import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

const Object _sentinel = Object();

/// Firestore `users` koleksiyonu için model sınıfı.
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String universityId;
  final String universityName;
  final String departmentId;
  final String departmentName;
  final int classYear;
  final int expectedGraduationYear;
  final String? profileImageUrl;
  final UserRole role;
  final bool isVerifiedStudent;
  final bool isBanned;
  final List<String> fcmTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.universityId,
    required this.universityName,
    required this.departmentId,
    required this.departmentName,
    required this.classYear,
    required this.expectedGraduationYear,
    this.profileImageUrl,
    this.role = UserRole.student,
    this.isVerifiedStudent = false,
    this.isBanned = false,
    this.fcmTokens = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Map (Firestore belge verisi) nesnesinden [UserProfile] oluşturur.
  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfile(
      id: id ?? map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      universityId: map['universityId'] as String? ?? '',
      universityName: map['universityName'] as String? ?? '',
      departmentId: map['departmentId'] as String? ?? '',
      departmentName: map['departmentName'] as String? ?? '',
      classYear: (map['classYear'] as num?)?.toInt() ?? 0,
      expectedGraduationYear:
          (map['expectedGraduationYear'] as num?)?.toInt() ?? 0,
      profileImageUrl: map['profileImageUrl'] as String?,
      role: UserRole.fromString(map['role'] as String?),
      isVerifiedStudent: map['isVerifiedStudent'] as bool? ?? false,
      isBanned: map['isBanned'] as bool? ?? false,
      fcmTokens: (map['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  /// [UserProfile] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'universityId': universityId,
      'universityName': universityName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'classYear': classYear,
      'expectedGraduationYear': expectedGraduationYear,
      'profileImageUrl': profileImageUrl,
      'role': role.value,
      'isVerifiedStudent': isVerifiedStudent,
      'isBanned': isBanned,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  ///
  /// Nullable alanlar ([phone], [profileImageUrl]) açıkça `null` geçilerek temizlenebilir (clear edilebilir).
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    Object? phone = _sentinel,
    String? universityId,
    String? universityName,
    String? departmentId,
    String? departmentName,
    int? classYear,
    int? expectedGraduationYear,
    Object? profileImageUrl = _sentinel,
    UserRole? role,
    bool? isVerifiedStudent,
    bool? isBanned,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: identical(phone, _sentinel) ? this.phone : (phone as String?),
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      classYear: classYear ?? this.classYear,
      expectedGraduationYear:
          expectedGraduationYear ?? this.expectedGraduationYear,
      profileImageUrl: identical(profileImageUrl, _sentinel)
          ? this.profileImageUrl
          : (profileImageUrl as String?),
      role: role ?? this.role,
      isVerifiedStudent: isVerifiedStudent ?? this.isVerifiedStudent,
      isBanned: isBanned ?? this.isBanned,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';

void main() {
  group('UserProfile Model Testleri', () {
    final now = DateTime(2026, 8, 13, 12, 0, 0);

    final sampleMap = <String, dynamic>{
      'id': 'user_123',
      'fullName': 'Ahmet Yılmaz',
      'email': 'ahmet@example.com',
      'phone': '+905551112233',
      'universityId': 'uni_itu',
      'universityName': 'İSTANBUL TEKNİK ÜNİVERSİTESİ',
      'departmentId': 'dep_cs',
      'departmentName': 'Bilgisayar Mühendisliği',
      'classYear': 3,
      'expectedGraduationYear': 2027,
      'profileImageUrl': 'https://example.com/avatar.jpg',
      'role': 'student',
      'isVerifiedStudent': true,
      'isBanned': false,
      'fcmTokens': ['token_1', 'token_2'],
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    test('fromMap doğru bir şekilde UserProfile oluşturur', () {
      final user = UserProfile.fromMap(sampleMap);

      expect(user.id, 'user_123');
      expect(user.fullName, 'Ahmet Yılmaz');
      expect(user.email, 'ahmet@example.com');
      expect(user.phone, '+905551112233');
      expect(user.universityId, 'uni_itu');
      expect(user.universityName, 'İSTANBUL TEKNİK ÜNİVERSİTESİ');
      expect(user.departmentId, 'dep_cs');
      expect(user.departmentName, 'Bilgisayar Mühendisliği');
      expect(user.classYear, 3);
      expect(user.expectedGraduationYear, 2027);
      expect(user.profileImageUrl, 'https://example.com/avatar.jpg');
      expect(user.role, UserRole.student);
      expect(user.isVerifiedStudent, true);
      expect(user.isBanned, false);
      expect(user.fcmTokens, ['token_1', 'token_2']);
      expect(user.createdAt, now);
      expect(user.updatedAt, now);
    });

    test('toMap doğru Map çıktısı üretir', () {
      final user = UserProfile.fromMap(sampleMap);
      final mapOutput = user.toMap();

      expect(mapOutput['id'], 'user_123');
      expect(mapOutput['fullName'], 'Ahmet Yılmaz');
      expect(mapOutput['role'], 'student');
      expect(mapOutput['createdAt'], isA<Timestamp>());
      expect((mapOutput['createdAt'] as Timestamp).toDate(), now);
    });

    test('copyWith alanları doğru bir şekilde günceller', () {
      final user = UserProfile.fromMap(sampleMap);
      final updatedUser = user.copyWith(
        fullName: 'Mehmet Yılmaz',
        role: UserRole.admin,
        isBanned: true,
      );

      expect(updatedUser.id, user.id);
      expect(updatedUser.fullName, 'Mehmet Yılmaz');
      expect(updatedUser.role, UserRole.admin);
      expect(updatedUser.isBanned, true);
      expect(updatedUser.email, user.email);
      expect(updatedUser.phone, '+905551112233'); // phone verilmediğinde eski değer korunur
    });

    test('copyWith nullable alanlar null geçildiğinde temizlenir (clear edilir)', () {
      final user = UserProfile.fromMap(sampleMap);
      expect(user.phone, isNotNull);
      expect(user.profileImageUrl, isNotNull);

      final clearedUser = user.copyWith(
        phone: null,
        profileImageUrl: null,
      );

      expect(clearedUser.phone, isNull);
      expect(clearedUser.profileImageUrl, isNull);
      expect(clearedUser.fullName, user.fullName);
    });

    test('Nullable alanlar ve varsayılan değerler doğru işlenir', () {
      final emptyMap = <String, dynamic>{};
      final user = UserProfile.fromMap(emptyMap, id: 'custom_id');

      expect(user.id, 'custom_id');
      expect(user.fullName, '');
      expect(user.phone, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.role, UserRole.student);
      expect(user.isVerifiedStudent, false);
      expect(user.isBanned, false);
      expect(user.fcmTokens, isEmpty);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('UserRole.fromString farklı roller için doğru döner', () {
      expect(UserRole.fromString('student'), UserRole.student);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('community'), UserRole.community);
      expect(UserRole.fromString('unknown'), UserRole.student);
      expect(UserRole.fromString(null), UserRole.student);
    });
  });
}

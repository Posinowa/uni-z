import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/shared/models/department_model.dart';

void main() {
  group('DepartmentModel Testleri', () {
    final now = DateTime(2026, 8, 13, 14, 0, 0);

    final sampleMap = <String, dynamic>{
      'id': 'dep_cs',
      'universityId': 'uni_itu',
      'name': 'Bilgisayar Mühendisliği',
      'isApproved': true,
      'createdBy': 'user_123',
      'createdAt': Timestamp.fromDate(now),
    };

    test('fromMap doğru bir şekilde DepartmentModel oluşturur', () {
      final department = DepartmentModel.fromMap(sampleMap);

      expect(department.id, 'dep_cs');
      expect(department.universityId, 'uni_itu');
      expect(department.name, 'Bilgisayar Mühendisliği');
      expect(department.isApproved, true);
      expect(department.createdBy, 'user_123');
      expect(department.createdAt, now);
    });

    test('toMap doğru Map çıktısı üretir ve round-trip destekler', () {
      final department = DepartmentModel.fromMap(sampleMap);
      final mapOutput = department.toMap();

      expect(mapOutput['id'], 'dep_cs');
      expect(mapOutput['universityId'], 'uni_itu');
      expect(mapOutput['name'], 'Bilgisayar Mühendisliği');
      expect(mapOutput['isApproved'], true);
      expect(mapOutput['createdBy'], 'user_123');
      expect(mapOutput['createdAt'], isA<Timestamp>());
      expect((mapOutput['createdAt'] as Timestamp).toDate(), now);

      // Round-trip doğrulama
      final reconstructed = DepartmentModel.fromMap(mapOutput);
      expect(reconstructed.id, department.id);
      expect(reconstructed.universityId, department.universityId);
      expect(reconstructed.name, department.name);
      expect(reconstructed.isApproved, department.isApproved);
      expect(reconstructed.createdBy, department.createdBy);
      expect(reconstructed.createdAt, department.createdAt);
    });

    test('copyWith alanları doğru günceller', () {
      final department = DepartmentModel.fromMap(sampleMap);
      final updated = department.copyWith(
        name: 'Yazılım Mühendisliği',
        isApproved: false,
      );

      expect(updated.id, 'dep_cs');
      expect(updated.universityId, 'uni_itu');
      expect(updated.name, 'Yazılım Mühendisliği');
      expect(updated.isApproved, false);
      expect(updated.createdBy, 'user_123');
      expect(updated.createdAt, now);
    });

    test('Boş veya eksik map ile varsayılan değerler atanır', () {
      final emptyMap = <String, dynamic>{};
      final department = DepartmentModel.fromMap(emptyMap, id: 'custom_id');

      expect(department.id, 'custom_id');
      expect(department.universityId, '');
      expect(department.name, '');
      expect(department.isApproved, false);
      expect(department.createdBy, '');
      expect(department.createdAt, isNull);
    });
  });
}

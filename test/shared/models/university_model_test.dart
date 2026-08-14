import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/shared/models/university_model.dart';

void main() {
  group('UniversityModel Testleri', () {
    final sampleMap = <String, dynamic>{
      'id': 'uni_itu',
      'name': 'İstanbul Teknik Üniversitesi',
      'city': 'İstanbul',
      'isActive': true,
    };

    test('fromMap doğru bir şekilde UniversityModel oluşturur', () {
      final university = UniversityModel.fromMap(sampleMap);

      expect(university.id, 'uni_itu');
      expect(university.name, 'İstanbul Teknik Üniversitesi');
      expect(university.city, 'İstanbul');
      expect(university.isActive, true);
    });

    test('toMap doğru Map çıktısı üretir ve round-trip destekler', () {
      final university = UniversityModel.fromMap(sampleMap);
      final mapOutput = university.toMap();

      expect(mapOutput['id'], 'uni_itu');
      expect(mapOutput['name'], 'İstanbul Teknik Üniversitesi');
      expect(mapOutput['city'], 'İstanbul');
      expect(mapOutput['isActive'], true);

      // Round-trip doğrulama
      final reconstructed = UniversityModel.fromMap(mapOutput);
      expect(reconstructed.id, university.id);
      expect(reconstructed.name, university.name);
      expect(reconstructed.city, university.city);
      expect(reconstructed.isActive, university.isActive);
    });

    test('copyWith alanları doğru günceller', () {
      final university = UniversityModel.fromMap(sampleMap);
      final updated = university.copyWith(
        name: 'İTÜ',
        isActive: false,
      );

      expect(updated.id, 'uni_itu');
      expect(updated.name, 'İTÜ');
      expect(updated.city, 'İstanbul');
      expect(updated.isActive, false);
    });

    test('Boş veya eksik map ile varsayılan değerler atanır', () {
      final emptyMap = <String, dynamic>{};
      final university = UniversityModel.fromMap(emptyMap, id: 'custom_id');

      expect(university.id, 'custom_id');
      expect(university.name, '');
      expect(university.city, '');
      expect(university.isActive, true);
    });
  });
}

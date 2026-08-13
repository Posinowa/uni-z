// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/features/profile/models/user_profile.dart';
import 'package:uniz_mobile/features/profile/models/user_role.dart';
import 'package:uniz_mobile/features/profile/services/profile_service.dart';

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, dynamic>> dataStore = {};
  final Map<String, FakeDocumentReference> docRefs = {};
  bool shouldThrow = false;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FakeCollectionReference(this, collectionPath);
  }
}

class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  final FirebaseFirestore firestore;
  @override
  final String path;

  FakeCollectionReference(this.firestore, this.path);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final docId = id ?? 'generated_id';
    return (firestore as FakeFirebaseFirestore).docRefs.putIfAbsent(
      docId,
      () => FakeDocumentReference(firestore, docId),
    );
  }
}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final FirebaseFirestore firestore;
  final String docId;
  final StreamController<DocumentSnapshot<Map<String, dynamic>>> _controller =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();

  FakeDocumentReference(this.firestore, this.docId);

  @override
  String get id => docId;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Set error');
    }
    fakeFs.dataStore[docId] = Map<String, dynamic>.from(data);
    _controller.add(FakeDocumentSnapshot(docId, fakeFs.dataStore[docId]));
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Get error');
    }
    return FakeDocumentSnapshot(docId, fakeFs.dataStore[docId]);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Update error');
    }
    if (!fakeFs.dataStore.containsKey(docId)) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Document not found',
      );
    }
    final current = fakeFs.dataStore[docId]!;
    data.forEach((key, value) {
      current[key.toString()] = value;
    });
    _controller.add(FakeDocumentSnapshot(docId, current));
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) async* {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Stream error');
    }
    yield FakeDocumentSnapshot(docId, fakeFs.dataStore[docId]);
    yield* _controller.stream;
  }
}

class FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic>? _data;

  FakeDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  bool get exists => _data != null;

  @override
  Map<String, dynamic>? data() => _data;
}

void main() {
  group('ProfileService Unit Testleri', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProfileService profileService;

    final testProfile = UserProfile(
      id: 'usr_123',
      fullName: 'Ahmet Yılmaz',
      email: 'ahmet@uniz.app',
      phone: '+905551234567',
      universityId: 'uni_itu',
      universityName: 'İSTANBUL TEKNİK ÜNİVERSİTESİ',
      departmentId: 'dep_cs',
      departmentName: 'Bilgisayar Mühendisliği',
      classYear: 3,
      expectedGraduationYear: 2027,
      role: UserRole.student,
      isVerifiedStudent: true,
      isBanned: false,
      fcmTokens: const ['fcm_1'],
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      profileService = ProfileService(firestoreInstance: fakeFirestore);
    });

    test('createUserProfile kullanıcı profilini doğru şekilde kaydeder', () async {
      await profileService.createUserProfile(testProfile);

      expect(fakeFirestore.dataStore.containsKey('usr_123'), isTrue);
      expect(fakeFirestore.dataStore['usr_123']?['fullName'], 'Ahmet Yılmaz');
      expect(fakeFirestore.dataStore['usr_123']?['email'], 'ahmet@uniz.app');
    });

    test('createUserProfile boş id ile çağrıldığında ArgumentError fırlatır', () async {
      const invalidProfile = UserProfile(
        id: '   ',
        fullName: 'Test',
        email: 'test@uniz.app',
        universityId: 'u1',
        universityName: 'U1',
        departmentId: 'd1',
        departmentName: 'D1',
        classYear: 1,
        expectedGraduationYear: 2026,
      );

      expect(
        () => profileService.createUserProfile(invalidProfile),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getUserProfile var olan kullanıcıyı başarıyla getirir', () async {
      await profileService.createUserProfile(testProfile);

      final result = await profileService.getUserProfile('usr_123');

      expect(result, isNotNull);
      expect(result!.id, 'usr_123');
      expect(result.fullName, 'Ahmet Yılmaz');
      expect(result.role, UserRole.student);
    });

    test('getUserProfile bulunamayan kullanıcı için null döner', () async {
      final result = await profileService.getUserProfile('non_existent_id');
      expect(result, isNull);
    });

    test('getUserProfile boş userId verildiğinde null döner', () async {
      final result = await profileService.getUserProfile('');
      expect(result, isNull);

      final resultWhitespace = await profileService.getUserProfile('   ');
      expect(resultWhitespace, isNull);
    });

    test('updateUserProfile mevcut kullanıcı verisini günceller', () async {
      await profileService.createUserProfile(testProfile);

      final updatedProfile = testProfile.copyWith(
        fullName: 'Ahmet Can Yılmaz',
        classYear: 4,
      );

      await profileService.updateUserProfile(updatedProfile);

      final fetched = await profileService.getUserProfile('usr_123');
      expect(fetched?.fullName, 'Ahmet Can Yılmaz');
      expect(fetched?.classYear, 4);
    });

    test('updateUserProfile boş id ile çağrıldığında ArgumentError fırlatır', () async {
      final invalidProfile = testProfile.copyWith(id: '');

      expect(
        () => profileService.updateUserProfile(invalidProfile),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('watchUserProfile değişiklikleri dinler ve anlık yayınlar', () async {
      final stream = profileService.watchUserProfile('usr_123');

      final results = <UserProfile?>[];
      final subscription = stream.listen(results.add);

      // 1. İlk durum: profil yok
      await Future.delayed(const Duration(milliseconds: 10));
      expect(results.length, 1);
      expect(results.first, isNull);

      // 2. Profil oluşturulur
      await profileService.createUserProfile(testProfile);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(results.length, 2);
      expect(results.last?.fullName, 'Ahmet Yılmaz');

      await subscription.cancel();
    });

    test('watchUserProfile boş userId verildiğinde null stream döner', () async {
      final stream = profileService.watchUserProfile('');
      final firstEmission = await stream.first;
      expect(firstEmission, isNull);
    });

    test('Firestore hata durumunda FirebaseException fırlatır', () async {
      fakeFirestore.shouldThrow = true;

      expect(
        () => profileService.createUserProfile(testProfile),
        throwsA(isA<FirebaseException>()),
      );

      expect(
        () => profileService.getUserProfile('usr_123'),
        throwsA(isA<FirebaseException>()),
      );

      expect(
        () => profileService.updateUserProfile(testProfile),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}

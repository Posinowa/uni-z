// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/features/reports/models/report_model.dart';
import 'package:uniz_mobile/features/reports/models/report_target_type.dart';
import 'package:uniz_mobile/features/reports/services/report_service.dart';

// ─── Fake Firestore Altyapısı ─────────────────────────────────────────────────
// ProfileService test pattern'i referans alınmıştır.

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
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Get error');
    }
    return FakeDocumentSnapshot(docId, fakeFs.dataStore[docId]);
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

// ─── Testler ──────────────────────────────────────────────────────────────────

void main() {
  group('ReportService Testleri', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ReportService reportService;

    final testReport = ReportModel(
      id: '',
      targetType: ReportTargetType.post,
      targetId: 'post_abc',
      reportedBy: 'user_123',
      reason: 'Uygunsuz içerik',
      createdAt: DateTime(2026, 9, 1),
    );

    /// Deterministic doc ID: userId_targetType_targetId
    const expectedDocId = 'user_123_post_post_abc';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      reportService = ReportService(firestoreInstance: fakeFirestore);
    });

    // ── createReport testleri ──

    test('createReport başarılı kayıt oluşturur (deterministic ID ile)', () async {
      await reportService.createReport(testReport);

      expect(fakeFirestore.dataStore.containsKey(expectedDocId), isTrue);
      expect(fakeFirestore.dataStore[expectedDocId]?['reportedBy'], 'user_123');
      expect(fakeFirestore.dataStore[expectedDocId]?['targetId'], 'post_abc');
      expect(fakeFirestore.dataStore[expectedDocId]?['targetType'], 'post');
      expect(fakeFirestore.dataStore[expectedDocId]?['reason'], 'Uygunsuz içerik');
    });

    test('createReport aynı rapor tekrar gönderildiğinde StateError fırlatır', () async {
      // İlk rapor başarılı.
      await reportService.createReport(testReport);

      // İkinci rapor StateError fırlatmalı.
      expect(
        () => reportService.createReport(testReport),
        throwsA(isA<StateError>()),
      );
    });

    test('createReport boş reportedBy ile ArgumentError fırlatır', () {
      final invalidReport = testReport.copyWith(reportedBy: '');
      expect(
        () => reportService.createReport(invalidReport),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createReport sadece boşluk içeren reportedBy ile ArgumentError fırlatır', () {
      final invalidReport = testReport.copyWith(reportedBy: '   ');
      expect(
        () => reportService.createReport(invalidReport),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createReport boş targetId ile ArgumentError fırlatır', () {
      final invalidReport = testReport.copyWith(targetId: '');
      expect(
        () => reportService.createReport(invalidReport),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createReport boş reason ile ArgumentError fırlatır', () {
      final invalidReport = testReport.copyWith(reason: '');
      expect(
        () => reportService.createReport(invalidReport),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createReport createdAt null ise otomatik atar', () async {
      final reportWithoutDate = ReportModel(
        id: '',
        targetType: ReportTargetType.post,
        targetId: 'post_xyz',
        reportedBy: 'user_456',
        reason: 'Spam',
      );

      await reportService.createReport(reportWithoutDate);

      const docId = 'user_456_post_post_xyz';
      expect(fakeFirestore.dataStore.containsKey(docId), isTrue);
      expect(fakeFirestore.dataStore[docId]?['createdAt'], isNotNull);
    });

    // ── hasUserReported testleri ──

    test('hasUserReported rapor varsa true döner', () async {
      await reportService.createReport(testReport);

      final result = await reportService.hasUserReported(
        targetType: 'post',
        targetId: 'post_abc',
        userId: 'user_123',
      );

      expect(result, isTrue);
    });

    test('hasUserReported rapor yoksa false döner', () async {
      final result = await reportService.hasUserReported(
        targetType: 'post',
        targetId: 'post_nonexistent',
        userId: 'user_123',
      );

      expect(result, isFalse);
    });

    test('hasUserReported boş targetType ile false döner', () async {
      final result = await reportService.hasUserReported(
        targetType: '',
        targetId: 'post_abc',
        userId: 'user_123',
      );
      expect(result, isFalse);
    });

    test('hasUserReported boş targetId ile false döner', () async {
      final result = await reportService.hasUserReported(
        targetType: 'post',
        targetId: '',
        userId: 'user_123',
      );
      expect(result, isFalse);
    });

    test('hasUserReported boş userId ile false döner', () async {
      final result = await reportService.hasUserReported(
        targetType: 'post',
        targetId: 'post_abc',
        userId: '',
      );
      expect(result, isFalse);
    });

    // ── Firestore hata testleri ──

    test('Firestore hata durumunda FirebaseException fırlatır', () async {
      fakeFirestore.shouldThrow = true;

      expect(
        () => reportService.createReport(testReport),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}

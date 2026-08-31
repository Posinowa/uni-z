// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/core/constants/firestore_collections.dart';
import 'package:uniz_mobile/features/feed/services/post_like_service.dart';

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, dynamic>> dataStore = {};
  final Map<String, FakeDocumentReference> docRefs = {};
  bool shouldThrow = false;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FakeCollectionReference(this, collectionPath);
  }

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Transaction error',
      );
    }
    final transaction = FakeTransaction(this);
    return await transactionHandler(transaction);
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
    final fullKey = '$path/$docId';
    return (firestore as FakeFirebaseFirestore).docRefs.putIfAbsent(
      fullKey,
      () => FakeDocumentReference(firestore, path, docId),
    );
  }
}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final FirebaseFirestore firestore;
  final String collectionPath;
  final String docId;
  final StreamController<DocumentSnapshot<Map<String, dynamic>>> _controller =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();

  FakeDocumentReference(this.firestore, this.collectionPath, this.docId);

  String get fullKey => '$collectionPath/$docId';

  @override
  String get id => docId;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Set error');
    }
    fakeFs.dataStore[fullKey] = Map<String, dynamic>.from(data);
    _controller.add(FakeDocumentSnapshot(docId, fakeFs.dataStore[fullKey]));
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(plugin: 'cloud_firestore', message: 'Get error');
    }
    return FakeDocumentSnapshot(docId, fakeFs.dataStore[fullKey]);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Update error',
      );
    }
    final current = fakeFs.dataStore[fullKey] ?? <String, dynamic>{};
    data.forEach((key, value) {
      current[key.toString()] = value;
    });
    fakeFs.dataStore[fullKey] = current;
    _controller.add(FakeDocumentSnapshot(docId, current));
  }

  @override
  Future<void> delete() async {
    final fakeFs = firestore as FakeFirebaseFirestore;
    if (fakeFs.shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Delete error',
      );
    }
    fakeFs.dataStore.remove(fullKey);
    _controller.add(FakeDocumentSnapshot(docId, null));
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) async* {
    final fakeFs = firestore as FakeFirebaseFirestore;
    yield FakeDocumentSnapshot(docId, fakeFs.dataStore[fullKey]);
    yield* _controller.stream;
  }
}

class FakeTransaction extends Fake implements Transaction {
  final FakeFirebaseFirestore firestore;

  FakeTransaction(this.firestore);

  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
    DocumentReference<T> documentReference,
  ) async {
    final docRef = documentReference as FakeDocumentReference;
    return (await docRef.get()) as DocumentSnapshot<T>;
  }

  @override
  Transaction set<T>(
    DocumentReference<T> documentReference,
    T data, [
    SetOptions? options,
  ]) {
    final docRef = documentReference as FakeDocumentReference;
    docRef.set(data as Map<String, dynamic>, options);
    return this;
  }

  @override
  Transaction update(
    DocumentReference<Object?> documentReference,
    Map<Object, Object?> data,
  ) {
    final docRef = documentReference as FakeDocumentReference;
    docRef.update(data);
    return this;
  }

  @override
  Transaction delete(DocumentReference<Object?> documentReference) {
    final docRef = documentReference as FakeDocumentReference;
    docRef.delete();
    return this;
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
  group('PostLikeService Unit Testleri', () {
    late FakeFirebaseFirestore fakeFirestore;
    late PostLikeService postLikeService;

    const testPostId = 'post_123';
    const testUserId = 'user_abc';
    final expectedLikeDocKey =
        '${FirestoreCollections.postLikes}/${testPostId}_$testUserId';
    final postDocKey = '${FirestoreCollections.posts}/$testPostId';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      postLikeService = PostLikeService(firestoreInstance: fakeFirestore);

      // Başlangıç post verisi
      fakeFirestore.dataStore[postDocKey] = {
        'id': testPostId,
        'likeCount': 5,
        'text': 'Test post içeriği',
      };
    });

    test('isPostLiked - Başlangıçta beğenilmemişse false döner', () async {
      final isLiked = await postLikeService.isPostLiked(
        postId: testPostId,
        userId: testUserId,
      );
      expect(isLiked, isFalse);
    });

    test('likePost - postLikes dokümanı oluşturur ve post likeCount 1 artar', () async {
      await postLikeService.likePost(
        postId: testPostId,
        userId: testUserId,
      );

      // Beğeni dokümanı oluştu mu?
      expect(fakeFirestore.dataStore.containsKey(expectedLikeDocKey), isTrue);
      expect(
        fakeFirestore.dataStore[expectedLikeDocKey]?['postId'],
        testPostId,
      );
      expect(
        fakeFirestore.dataStore[expectedLikeDocKey]?['userId'],
        testUserId,
      );

      // Post likeCount 6 oldu mu?
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 6);

      // isPostLiked true dönmeli
      final isLiked = await postLikeService.isPostLiked(
        postId: testPostId,
        userId: testUserId,
      );
      expect(isLiked, isTrue);
    });

    test('likePost - Aynı kullanıcı ikinci kez beğenemez (çift like engeli)', () async {
      await postLikeService.likePost(
        postId: testPostId,
        userId: testUserId,
      );
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 6);

      // İkinci kez like çağrısı
      await postLikeService.likePost(
        postId: testPostId,
        userId: testUserId,
      );
      // likeCount tekrar artmamalı, 6 kalmalı
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 6);
    });

    test('unlikePost - postLikes dokümanı silinir ve post likeCount 1 azalır', () async {
      // Önce like yap
      await postLikeService.likePost(
        postId: testPostId,
        userId: testUserId,
      );
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 6);

      // Şimdi unlike yap
      await postLikeService.unlikePost(
        postId: testPostId,
        userId: testUserId,
      );

      expect(fakeFirestore.dataStore.containsKey(expectedLikeDocKey), isFalse);
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 5);

      final isLiked = await postLikeService.isPostLiked(
        postId: testPostId,
        userId: testUserId,
      );
      expect(isLiked, isFalse);
    });

    test('unlikePost - likeCount asla negatif olmaz', () async {
      // Post likeCount = 0 yapalım
      fakeFirestore.dataStore[postDocKey]?['likeCount'] = 0;
      // Dokümanı var edelim
      fakeFirestore.dataStore[expectedLikeDocKey] = {
        'id': '${testPostId}_$testUserId',
        'postId': testPostId,
        'userId': testUserId,
      };

      await postLikeService.unlikePost(
        postId: testPostId,
        userId: testUserId,
      );

      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 0);
    });

    test('toggleLike - Beğenilmemişse beğenir (true döner), beğenilmişse kaldırır (false döner)', () async {
      // 1. Toggle -> Like olmalı
      final result1 = await postLikeService.toggleLike(
        postId: testPostId,
        userId: testUserId,
      );
      expect(result1, isTrue);
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 6);
      expect(fakeFirestore.dataStore.containsKey(expectedLikeDocKey), isTrue);

      // 2. Toggle -> Unlike olmalı
      final result2 = await postLikeService.toggleLike(
        postId: testPostId,
        userId: testUserId,
      );
      expect(result2, isFalse);
      expect(fakeFirestore.dataStore[postDocKey]?['likeCount'], 5);
      expect(fakeFirestore.dataStore.containsKey(expectedLikeDocKey), isFalse);
    });

    test('watchIsPostLiked - Stream anlık güncellenir', () async {
      final stream = postLikeService.watchIsPostLiked(
        postId: testPostId,
        userId: testUserId,
      );

      expect(
        stream,
        emitsInOrder([
          false, // ilk durum
          true,  // like sonrası
          false, // unlike sonrası
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await postLikeService.likePost(postId: testPostId, userId: testUserId);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await postLikeService.unlikePost(postId: testPostId, userId: testUserId);
    });

    test('Geçersiz / boş parametre durumlarında hata fırlatılır', () {
      expect(
        () => postLikeService.likePost(postId: '', userId: testUserId),
        throwsArgumentError,
      );
      expect(
        () => postLikeService.unlikePost(postId: testPostId, userId: ''),
        throwsArgumentError,
      );
    });
  });
}

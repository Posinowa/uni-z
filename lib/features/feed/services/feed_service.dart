import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/post_model.dart';
import '../models/post_status.dart';

/// Firestore `posts` koleksiyonu üzerindeki okuma/yazma işlemlerini yöneten servis sınıfı.
///
/// UI bağımlılığı içermez.
/// Hata durumlarında Firestore istisnaları üst katmana fırlatılır.
class FeedService extends FirestoreService {
  /// [FeedService] oluşturur.
  ///
  /// Testlerde sahte/mock instance verebilmek için opsiyonel [firestoreInstance] kabul eder.
  FeedService({super.firestoreInstance})
      : super(FirestoreCollections.posts);

  /// Yeni gönderiyi Firestore `posts` koleksiyonuna kaydeder.
  ///
  /// [post] nesnesinin `id` değeri belge kimliği (document ID) olarak kullanılır.
  /// Boş `id` durumunda [ArgumentError] fırlatır.
  Future<void> createPost(PostModel post) async {
    if (post.id.trim().isEmpty) {
      throw ArgumentError('Gönderi kimliği (id) boş olamaz.');
    }

    final now = Timestamp.fromDate(DateTime.now());
    final createdAt =
        post.createdAt != null ? Timestamp.fromDate(post.createdAt!) : now;
    final updatedAt =
        post.updatedAt != null ? Timestamp.fromDate(post.updatedAt!) : now;
    final postData = post.toMap()
      ..update(
        'createdAt',
        (_) => createdAt,
        ifAbsent: () => createdAt,
      )
      ..update(
        'updatedAt',
        (_) => updatedAt,
        ifAbsent: () => updatedAt,
      );

    await collection.doc(post.id).set(postData);
  }

  /// Yayında olan gönderileri `createdAt` alanına göre azalan sırada dinler.
  ///
  /// Sadece `status == published` olan gönderiler döner.
  Stream<List<PostModel>> watchPublishedPosts() {
    return collection
        .where('status', isEqualTo: PostStatus.published.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Belirtilen gönderiyi gizler (`status: hidden`).
  ///
  /// [postId] boş ise [ArgumentError] fırlatır.
  Future<void> hidePost(String postId) async {
    await _updatePostStatus(postId, PostStatus.hidden);
  }

  /// Belirtilen gönderiyi kaldırır (`status: removed`).
  ///
  /// [postId] boş ise [ArgumentError] fırlatır.
  Future<void> removePost(String postId) async {
    await _updatePostStatus(postId, PostStatus.removed);
  }

  Future<void> _updatePostStatus(String postId, PostStatus status) async {
    if (postId.trim().isEmpty) {
      throw ArgumentError('Gönderi kimliği (id) boş olamaz.');
    }

    await collection.doc(postId).update({
      'status': status.value,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

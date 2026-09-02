import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/feed_post.dart';
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

  /// Yeni bir metin veya görsel gönderiyi Firestore `posts` koleksiyonuna kaydeder.
  ///
  /// Gönderi ID'si boşsa Firestore tarafından yeni bir belge kimliği atanır.
  /// İşlem başarılı olursa oluşturulan gönderinin kimliğini (ID) döner.
  Future<String> createPost(FeedPost post) async {
    final docRef =
        post.id.trim().isEmpty ? collection.doc() : collection.doc(post.id);

    final createdAt = post.createdAt != null
        ? Timestamp.fromDate(post.createdAt!)
        : FieldValue.serverTimestamp();
    final updatedAt = post.updatedAt != null
        ? Timestamp.fromDate(post.updatedAt!)
        : FieldValue.serverTimestamp();

    final postData = post.copyWith(id: docRef.id).toMap()
      ..['createdAt'] = createdAt
      ..['updatedAt'] = updatedAt;

    await docRef.set(postData);
    return docRef.id;
  }

  /// Yayında olan gönderileri `createdAt` alanına göre azalan sırada dinler.
  ///
  /// Sadece `status == published` olan gönderiler döner.
  Stream<List<FeedPost>> watchPublishedPosts() {
    return collection
        .where('status', isEqualTo: PostStatus.published.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedPost.fromMap(doc.data(), id: doc.id))
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

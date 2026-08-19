/// Ana akış gönderi durumlarını tanımlayan enum.
///
/// Firestore `posts` koleksiyonundaki `status` alanına karşılık gelir.
enum PostStatus {
  published('published'),
  hidden('hidden'),
  removed('removed');

  final String value;
  const PostStatus(this.value);

  /// String değerden [PostStatus] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [PostStatus.published] döner.
  static PostStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'hidden':
        return PostStatus.hidden;
      case 'removed':
        return PostStatus.removed;
      case 'published':
      default:
        return PostStatus.published;
    }
  }
}

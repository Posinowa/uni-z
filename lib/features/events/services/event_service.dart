import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/event_model.dart';
import '../models/event_status.dart';

/// Firestore `events` koleksiyonu üzerindeki okuma ve yazma işlemlerini yöneten servis sınıfı.
///
/// UI bağımlılığı içermez.
/// Hata durumlarında Firestore istisnaları üst katmana fırlatılır.
class EventService extends FirestoreService {
  /// [EventService] oluşturur.
  ///
  /// Testlerde sahte/mock instance enjekte edebilmek için opsiyonel [firestoreInstance] kabul eder.
  EventService({super.firestoreInstance}) : super(FirestoreCollections.events);

  /// Sadece onaylanmış (`status == approved`) etkinlikleri tarihe (`eventDate`) göre sıralı olarak dinler.
  ///
  /// - [descending]: `false` (varsayılan) ise en yakın etkinlikten ileri tarihe doğru artan sıralar.
  /// - [universityId]: Belirtilirse sadece o üniversiteye ait onaylı etkinlikleri filtreler.
  Stream<List<EventModel>> watchApprovedEvents({
    String? universityId,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = collection
        .where('status', isEqualTo: EventStatus.approved.value);

    if (universityId != null && universityId.trim().isNotEmpty) {
      query = query.where('universityId', isEqualTo: universityId.trim());
    }

    return query
        .orderBy('eventDate', descending: descending)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Yeni bir etkinlik oluşturma talebini Firestore `events` koleksiyonuna `pending` statüsüyle kaydeder.
  ///
  /// - [event] nesnesinin durumu her zaman [EventStatus.pending] olarak atanır.
  /// - Etkinlik kimliği (`id`) boş ise Firestore tarafından otomatik yeni bir belge kimliği üretilir.
  /// - `createdAt` alanı boş ise sunucu zaman damgası (`FieldValue.serverTimestamp()`) atanır.
  /// - Onay alanları (`approvedBy`, `approvedAt`) bekleyen etkinlik için `null` olarak ayarlanır.
  Future<void> createPendingEvent(EventModel event) async {
    final docRef =
        event.id.trim().isEmpty ? collection.doc() : collection.doc(event.id);

    final createdAt = event.createdAt != null
        ? Timestamp.fromDate(event.createdAt!)
        : FieldValue.serverTimestamp();

    final eventData = event
        .copyWith(
          id: docRef.id,
          status: EventStatus.pending,
          approvedBy: null,
          approvedAt: null,
        )
        .toMap()
      ..['createdAt'] = createdAt;

    await docRef.set(eventData);
  }

  /// Belirtilen [eventId] kimliğine sahip etkinliği getirir.
  ///
  /// - Belge bulunamazsa veya [eventId] boş ise `null` döner.
  Future<EventModel?> getEventById(String eventId) async {
    final cleanId = eventId.trim();
    if (cleanId.isEmpty) {
      return null;
    }

    final docSnapshot = await collection.doc(cleanId).get();
    final data = docSnapshot.data();

    if (!docSnapshot.exists || data == null) {
      return null;
    }

    return EventModel.fromMap(data, id: docSnapshot.id);
  }
}

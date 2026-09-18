import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/states/states.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';

/// Kampüs etkinliklerinin listelendiği ana ekran.
///
/// Firestore `events` koleksiyonundaki onaylanmış (`approved`) etkinlikleri
/// tarihe göre artan sırada (yaklaşan etkinlikler önce) dinler ve listeler.
///
/// Üç temel durum yönetilir:
/// - **Loading:** Veri beklenirken spinner gösterir.
/// - **Empty:** Hiç onaylanmış etkinlik yoksa bilgilendirici boş ekran gösterir.
/// - **Error:** Bağlantı veya Firestore hatasında hata ekranı ve tekrar dene butonu gösterir.
class EventsScreen extends StatefulWidget {
  /// Testler ve özel durumlar için opsiyonel servis veya stream enjeksiyonu.
  final EventService? eventService;
  final Stream<List<EventModel>>? eventsStream;

  const EventsScreen({
    super.key,
    this.eventService,
    this.eventsStream,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventService? _eventService;
  late Stream<List<EventModel>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  /// Onaylanmış etkinlikleri dinleyen stream'i başlatır.
  ///
  /// `descending: false` ile yaklaşan etkinlikler (en yakın tarihli) en önce listelenir.
  void _initStream() {
    if (widget.eventsStream != null) {
      _eventsStream = widget.eventsStream!;
    } else {
      _eventService ??= widget.eventService ?? EventService();
      _eventsStream = _eventService!.watchApprovedEvents(descending: false);
    }
  }

  /// Hata veya yenileme durumunda stream'i yeniden bağlar.
  void _retry() {
    setState(() {
      _initStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          // ─── Yükleniyor Durumu ────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          // ─── Hata Durumu ──────────────────────────────────────
          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Etkinlikler yüklenemedi',
              message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
              onRetry: _retry,
            );
          }

          final events = snapshot.data ?? [];

          // ─── Boş Durum ────────────────────────────────────────
          if (events.isEmpty) {
            return AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Henüz etkinlik yok',
              description:
                  'Yakında yeni kampüs etkinlikleri burada listelenecektir.',
              actionText: 'Yenile',
              onActionPressed: _retry,
            );
          }

          // ─── Etkinlik Listesi ─────────────────────────────────
          return RefreshIndicator(
            color: AppColors.categoryEvents,
            onRefresh: () async {
              _retry();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.xl,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${event.title} detayları yakında eklenecek.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

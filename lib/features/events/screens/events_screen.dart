import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/states/states.dart';
import '../models/event_model.dart';
import '../models/event_status.dart';
import '../widgets/event_card.dart';

/// Ekranın mevcut durumunu temsil eden enum.
enum EventsViewState {
  content,
  loading,
  empty,
  error,
}

/// Kampüs etkinliklerinin listelendiği ana ekran.
///
/// Bu aşamada Firestore bağlantısı kapsam dışıdır.
/// Ekran; içerik, yükleniyor (loading), boş (empty) ve hata (error) durumlarını
/// yönetir ve görüntüler.
class EventsScreen extends StatefulWidget {
  /// Ekranın başlangıç durumu (testler ve önizlemeler için yapılandırılabilir).
  final EventsViewState initialState;

  /// Gösterilecek başlangıç etkinlik listesi (opsiyonel).
  final List<EventModel>? initialEvents;

  const EventsScreen({
    super.key,
    this.initialState = EventsViewState.content,
    this.initialEvents,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late EventsViewState _currentState;
  late List<EventModel> _events;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _events = widget.initialEvents ?? _getSampleEvents();
  }

  /// Yenileme veya tekrar deneme simülasyonu.
  Future<void> _handleRefresh() async {
    setState(() => _currentState = EventsViewState.loading);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _events = _getSampleEvents();
        _currentState = EventsViewState.content;
      });
    }
  }

  /// Hata durumundan kurtulmak için tekrar deneme.
  void _handleRetry() {
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        actions: [
          // UI inceleme ve test kolaylığı için durum değiştirici menü
          PopupMenuButton<EventsViewState>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Görünüm Durumu',
            onSelected: (state) {
              setState(() {
                _currentState = state;
                if (state == EventsViewState.empty) {
                  _events = [];
                } else if (state == EventsViewState.content) {
                  _events = _getSampleEvents();
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: EventsViewState.content,
                child: Text('Etkinlik Listesi'),
              ),
              const PopupMenuItem(
                value: EventsViewState.loading,
                child: Text('Yükleniyor (Loading)'),
              ),
              const PopupMenuItem(
                value: EventsViewState.empty,
                child: Text('Boş Durum (Empty)'),
              ),
              const PopupMenuItem(
                value: EventsViewState.error,
                child: Text('Hata Durumu (Error)'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Mevcut duruma göre gövde widget'ını oluşturur.
  Widget _buildBody() {
    switch (_currentState) {
      case EventsViewState.loading:
        return const AppLoadingView();

      case EventsViewState.error:
        return AppErrorState(
          title: 'Etkinlikler yüklenemedi',
          message: 'Bir bağlantı hatası oluştu. Lütfen tekrar deneyin.',
          onRetry: _handleRetry,
        );

      case EventsViewState.empty:
        return AppEmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Henüz etkinlik yok',
          description: 'Yakında yeni kampüs etkinlikleri burada listelenecektir.',
          actionText: 'Yenile',
          onActionPressed: _handleRefresh,
        );

      case EventsViewState.content:
        if (_events.isEmpty) {
          return AppEmptyState(
            icon: Icons.event_busy_outlined,
            title: 'Henüz etkinlik yok',
            description: 'Yakında yeni kampüs etkinlikleri burada listelenecektir.',
            actionText: 'Yenile',
            onActionPressed: _handleRefresh,
          );
        }

        return RefreshIndicator(
          color: AppColors.categoryEvents,
          onRefresh: _handleRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.xl,
            ),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return EventCard(
                event: event,
                onTap: () {
                  // Event detail bu issue kapsamında yer almamaktadır
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${event.title} detayları yakında eklenecek.'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }

  /// Örnek etkinlik verileri.
  static List<EventModel> _getSampleEvents() {
    return [
      EventModel(
        id: 'event-1',
        title: 'Yazılım & Teknoloji Zirvesi 2026',
        description: 'Sektörün lider mühendisleri ve teknoloji liderleri kampüste!',
        universityId: 'itu',
        location: 'Süleyman Demirel Kültür Merkezi, Maslak',
        eventDate: DateTime(2026, 10, 15, 10, 30),
        imageUrl: null, // Görsel placeholder'ını doğrulamak için null
        createdBy: 'user-itu-1',
        organizerName: 'İTÜ ACM Öğrenci Kulübü',
        status: EventStatus.approved,
        createdAt: DateTime(2026, 9, 1),
        approvedBy: 'admin-1',
        approvedAt: DateTime(2026, 9, 2),
      ),
      EventModel(
        id: 'event-2',
        title: 'Sonbahar Kariyer & Staj Fuarı',
        description: '50+ kurumsal firma ile doğrudan tanışma ve staj mülakatları.',
        universityId: 'boun',
        location: 'Albert Long Hall, Güney Kampüs',
        eventDate: DateTime(2026, 10, 22, 11, 00),
        imageUrl: null,
        createdBy: 'user-boun-1',
        organizerName: 'Kariyer ve Gelişim Kulübü',
        status: EventStatus.approved,
        createdAt: DateTime(2026, 9, 3),
        approvedBy: 'admin-1',
        approvedAt: DateTime(2026, 9, 3),
      ),
      EventModel(
        id: 'event-3',
        title: 'Yapay Zeka ve Büyük Dil Modelleri Çalıştayı',
        description: 'Hands-on yapay zeka atölyesi ve model geliştirme oturumu.',
        universityId: 'odtu',
        location: 'Bilgisayar Mühendisliği Amfisi A-101',
        eventDate: DateTime(2026, 11, 5, 14, 00),
        imageUrl: null,
        createdBy: 'user-odtu-1',
        organizerName: 'IEEE Öğrenci Kolu',
        status: EventStatus.approved,
        createdAt: DateTime(2026, 9, 4),
        approvedBy: 'admin-1',
        approvedAt: DateTime(2026, 9, 5),
      ),
    ];
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../profile/models/user_role.dart';
import '../../profile/services/profile_service.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

/// Yetkili kullanıcıların (community veya admin) etkinlik oluşturma talebi
/// gönderebileceği form ekranı.
///
/// - `student` rolündeki kullanıcılara form gösterilmez; açıklama mesajı gösterilir.
/// - Yetkili kullanıcılar formu doldurup gönderebilir.
/// - Submit sonrası etkinlik Firestore'a `status: pending` olarak kaydedilir.
///
/// Kapsam dışı:
/// - Gerçek görsel upload yok (opsiyonel URL alanı var).
/// - Admin onay akışı yok.
class CreateEventScreen extends StatefulWidget {
  final EventService? eventService;
  final ProfileService? profileService;
  final FirebaseAuth? authInstance;

  const CreateEventScreen({
    super.key,
    this.eventService,
    this.profileService,
    this.authInstance,
  });

  /// [CreateEventScreen] sayfasına yönlendirme sağlayan standart route üretici.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CreateEventScreen(),
    );
  }

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late final EventService _eventService;
  late final ProfileService _profileService;
  late final FirebaseAuth _auth;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // null = yükleniyor, true = yetkili, false = yetkisiz
  bool? _isAuthorized;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventService = widget.eventService ?? EventService();
    _profileService = widget.profileService ?? ProfileService();
    _auth = widget.authInstance ?? FirebaseAuth.instance;
    _checkRole();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Kullanıcının rolünü Firestore'dan okur ve yetki durumunu belirler.
  Future<void> _checkRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _isAuthorized = false);
      return;
    }

    final profile = await _profileService.getUserProfile(uid);
    final role = profile?.role ?? UserRole.student;

    setState(() {
      _isAuthorized = role == UserRole.community || role == UserRole.admin;
    });
  }

  /// Tarih seçici diyaloğunu açar.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.categoryEvents,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Saat seçici diyaloğunu açar.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.categoryEvents,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Formu doğrular ve Firestore'a pending etkinlik olarak kaydeder.
  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tarih ve saat seçin.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final profile = await _profileService.getUserProfile(uid);

      // Etkinlik tarihini seçilen gün ve saatten oluştur
      final eventDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final imageUrl = _imageUrlController.text.trim();

      final event = EventModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        universityId: profile?.universityId ?? '',
        location: _locationController.text.trim(),
        eventDate: eventDate,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        createdBy: uid,
        organizerName: profile?.fullName ?? '',
      );

      await _eventService.createPendingEvent(event);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Etkinlik talebiniz alındı. Admin onayından sonra yayınlanacaktır.',
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Etkinlik Oluştur'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Yükleniyor — rol kontrolü bekleniyor
    if (_isAuthorized == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.categoryEvents),
      );
    }

    // Yetkisiz kullanıcı
    if (_isAuthorized == false) {
      return _buildUnauthorizedView();
    }

    // Yetkili kullanıcı — form
    return _buildForm();
  }

  /// Yetkisiz kullanıcı için açıklama görünümü.
  Widget _buildUnauthorizedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.categoryEvents.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: AppColors.categoryEvents,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bu özellik kullanılamıyor',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Etkinlik oluşturmak için topluluk (community) veya admin yetkisine sahip olmanız gerekmektedir.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Yetkili kullanıcı için etkinlik oluşturma formu.
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Başlık ────────────────────────────────────────────────
            AppTextField(
              label: 'Başlık',
              hint: 'Etkinlik başlığı',
              controller: _titleController,
              prefixIcon: Icons.title_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlık zorunludur.';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Açıklama ──────────────────────────────────────────────
            AppTextField(
              label: 'Açıklama',
              hint: 'Etkinlik hakkında kısa bilgi verin',
              controller: _descriptionController,
              maxLines: 4,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Açıklama zorunludur.';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Konum ─────────────────────────────────────────────────
            AppTextField(
              label: 'Konum',
              hint: 'Örn: A Blok Amfi, Kütüphane Salonu',
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Konum zorunludur.';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Tarih ve Saat (Yan Yana) ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DateTimePickerField(
                    label: 'Tarih',
                    icon: Icons.calendar_today_outlined,
                    value: _selectedDate != null
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}.'
                            '${_selectedDate!.month.toString().padLeft(2, '0')}.'
                            '${_selectedDate!.year}'
                        : null,
                    hint: 'Seçin',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DateTimePickerField(
                    label: 'Saat',
                    icon: Icons.access_time_outlined,
                    value: _selectedTime != null
                        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
                            '${_selectedTime!.minute.toString().padLeft(2, '0')}'
                        : null,
                    hint: 'Seçin',
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Görsel URL (Opsiyonel) ────────────────────────────────
            AppTextField(
              label: 'Görsel URL (opsiyonel)',
              hint: 'https://...',
              controller: _imageUrlController,
              prefixIcon: Icons.image_outlined,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'Gerçek görsel yükleme özelliği yakında eklenecektir.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ─── Submit Butonu ─────────────────────────────────────────
            PrimaryButton(
              key: const Key('create_event_submit_button'),
              text: 'Etkinlik Talebi Gönder',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submitForm,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ─── Bilgilendirme Notu ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Etkinliğiniz admin onayından geçtikten sonra herkese görünür hale gelecektir.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Tarih / saat seçici için dokunulabilir alan bileşeni.
class _DateTimePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final String hint;
  final VoidCallback onTap;

  const _DateTimePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: hasValue
                  ? AppColors.categoryEvents
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value! : hint,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

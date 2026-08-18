import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_dropdown_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';

/// Bölüm seçimi veya manuel giriş yapılabilen form alanı.
///
/// Kullanıcı listede bölümünü bulamazsa "Listede yok, yazayım" bağlantısına
/// tıklayarak metin kutusuna geçer. Her iki modda da validasyon çalışır.
///
/// Seçilen/girilen bölüm adı [onDepartmentChanged] ile üst widget'a iletilir.
///
/// Örnek:
/// ```dart
/// DepartmentInputField(
///   onDepartmentChanged: (value) => setState(() => _department = value),
/// )
/// ```
class DepartmentInputField extends StatefulWidget {
  const DepartmentInputField({
    required this.onDepartmentChanged,
    super.key,
  });

  /// Bölüm adı değiştiğinde çağrılır. Temizlendiğinde `null` gönderilir.
  final ValueChanged<String?> onDepartmentChanged;

  @override
  State<DepartmentInputField> createState() => _DepartmentInputFieldState();
}

class _DepartmentInputFieldState extends State<DepartmentInputField> {
  /// `true` → kullanıcı manuel bölüm adı giriyor.
  bool _isManualEntry = false;

  /// Dropdown'da seçili bölüm.
  String? _selectedDepartment;

  /// Manuel giriş için controller.
  final _manualController = TextEditingController();

  // Hazır bölüm listesi — ilerleyen sürümlerde Firestore'dan çekilecek.
  static const List<String> _departments = [
    'Bilgisayar Mühendisliği',
    'Yazılım Mühendisliği',
    'Elektrik-Elektronik Mühendisliği',
    'Makine Mühendisliği',
    'Endüstri Mühendisliği',
    'İnşaat Mühendisliği',
    'İşletme',
    'İktisat',
    'Hukuk',
    'Tıp',
    'Psikoloji',
    'Matematik',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Mimarlık',
    'İletişim',
    'Eğitim',
    'Hemşirelik',
    'Eczacılık',
  ];

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  /// Dropdown moduna geçer ve mevcut seçimi temizler.
  void _switchToDropdown() {
    setState(() {
      _isManualEntry = false;
      _manualController.clear();
    });
    widget.onDepartmentChanged(null);
  }

  /// Manuel giriş moduna geçer ve dropdown seçimini temizler.
  void _switchToManual() {
    setState(() {
      _isManualEntry = true;
      _selectedDepartment = null;
    });
    widget.onDepartmentChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bölüm Giriş Alanı ──
        if (_isManualEntry)
          _buildManualField()
        else
          _buildDropdown(),

        const SizedBox(height: AppSpacing.sm),

        // ── Mod Değiştirme Bağlantısı ──
        _buildToggleLink(),

        const SizedBox(height: AppSpacing.sm),

        // ── Bilgi Metni ──
        _buildInfoText(),
      ],
    );
  }

  /// Hazır listeden bölüm seçimi dropdown'u.
  Widget _buildDropdown() {
    return AppDropdownField<String>(
      label: 'Bölüm',
      hint: 'Bölümünüzü seçin',
      value: _selectedDepartment,
      prefixIcon: Icons.menu_book_outlined,
      items: _departments
          .map(
            (dept) => DropdownMenuItem(
              value: dept,
              child: Text(dept),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _selectedDepartment = value);
        widget.onDepartmentChanged(value);
      },
      validator: (value) {
        if (value == null) return 'Bölüm seçimi zorunludur';
        return null;
      },
    );
  }

  /// Kullanıcının bölüm adını elle girdiği metin kutusu.
  Widget _buildManualField() {
    return AppTextField(
      label: 'Bölüm Adı',
      hint: 'Bölümünüzü yazın',
      controller: _manualController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.edit_outlined,
      onChanged: widget.onDepartmentChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bölüm adı gerekli';
        }
        return null;
      },
    );
  }

  /// Modlar arası geçiş bağlantısı.
  Widget _buildToggleLink() {
    return GestureDetector(
      onTap: _isManualEntry ? _switchToDropdown : _switchToManual,
      child: Text(
        _isManualEntry
            ? '← Listeden seçmek istiyorum'
            : 'Bölümünüz listede yok mu? Yazın',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primaryIndigo,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryIndigo,
        ),
      ),
    );
  }

  /// Issue gereği gösterilmesi zorunlu açıklama metni.
  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.primaryIndigo.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.primaryIndigo,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Bölümünüz listede yoksa yazabilirsiniz. '
              'Yeni bölüm bilgileri admin onayından sonra sisteme eklenir.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryIndigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

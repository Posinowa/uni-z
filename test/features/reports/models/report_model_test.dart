import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/features/reports/models/report_model.dart';
import 'package:uniz_mobile/features/reports/models/report_reason.dart';
import 'package:uniz_mobile/features/reports/models/report_status.dart';
import 'package:uniz_mobile/features/reports/models/report_target_type.dart';

void main() {
  group('ReportModel Testleri', () {
    final testDate = DateTime(2026, 9, 1, 12, 0);

    final fullMap = <String, dynamic>{
      'id': 'report_1',
      'targetType': 'post',
      'targetId': 'post_abc',
      'reportedBy': 'user_123',
      'reason': 'inappropriate_content',
      'description': 'Hakaret içeriyor',
      'status': 'open',
      'createdAt': Timestamp.fromDate(testDate),
      'reviewedBy': 'admin_1',
      'reviewedAt': Timestamp.fromDate(testDate),
    };

    final testReport = ReportModel(
      id: 'report_1',
      targetType: ReportTargetType.post,
      targetId: 'post_abc',
      reportedBy: 'user_123',
      reason: 'inappropriate_content',
      description: 'Hakaret içeriyor',
      status: ReportStatus.open,
      createdAt: testDate,
      reviewedBy: 'admin_1',
      reviewedAt: testDate,
    );

    // ── fromMap testleri ──

    test('fromMap tam veriyle doğru model oluşturur', () {
      final model = ReportModel.fromMap(fullMap);

      expect(model.id, 'report_1');
      expect(model.targetType, ReportTargetType.post);
      expect(model.targetId, 'post_abc');
      expect(model.reportedBy, 'user_123');
      expect(model.reason, 'inappropriate_content');
      expect(model.reasonEnum, ReportReason.inappropriateContent);
      expect(model.description, 'Hakaret içeriyor');
      expect(model.status, ReportStatus.open);
      expect(model.createdAt, testDate);
      expect(model.reviewedBy, 'admin_1');
      expect(model.reviewedAt, testDate);
    });

    test('fromMap eksik/null alanlarla varsayılan değerler atar', () {
      final model = ReportModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.targetType, ReportTargetType.post);
      expect(model.targetId, '');
      expect(model.reportedBy, '');
      expect(model.reason, '');
      expect(model.reasonEnum, ReportReason.other);
      expect(model.description, isNull);
      expect(model.status, ReportStatus.open);
      expect(model.createdAt, isNull);
      expect(model.reviewedBy, isNull);
      expect(model.reviewedAt, isNull);
    });

    test('fromMap id parametresi map değerini override eder', () {
      final model = ReportModel.fromMap(fullMap, id: 'custom_id');
      expect(model.id, 'custom_id');
    });

    // ── toMap testleri ──

    test('toMap id alanını içermez (doc ID tutarlılığı) ve doğru Map çıktısı üretir', () {
      final map = testReport.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['targetType'], 'post');
      expect(map['targetId'], 'post_abc');
      expect(map['reportedBy'], 'user_123');
      expect(map['reason'], 'inappropriate_content');
      expect(map['description'], 'Hakaret içeriyor');
      expect(map['status'], 'open');
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['reviewedBy'], 'admin_1');
      expect(map['reviewedAt'], isA<Timestamp>());
    });

    test('toMap → fromMap round-trip tutarlıdır', () {
      final map = testReport.toMap();
      final restored = ReportModel.fromMap(map, id: testReport.id);

      expect(restored.id, testReport.id);
      expect(restored.targetType, testReport.targetType);
      expect(restored.targetId, testReport.targetId);
      expect(restored.reportedBy, testReport.reportedBy);
      expect(restored.reason, testReport.reason);
      expect(restored.reasonEnum, testReport.reasonEnum);
      expect(restored.description, testReport.description);
      expect(restored.status, testReport.status);
      expect(restored.createdAt, testReport.createdAt);
    });

    // ── copyWith testleri ──

    test('copyWith alanları günceller', () {
      final updated = testReport.copyWith(
        reason: 'spam_misleading',
        status: ReportStatus.reviewed,
      );

      expect(updated.reason, 'spam_misleading');
      expect(updated.reasonEnum, ReportReason.spamMisleading);
      expect(updated.status, ReportStatus.reviewed);
      // Değişmeyen alanlar korunur.
      expect(updated.id, testReport.id);
      expect(updated.targetType, testReport.targetType);
    });

    test('copyWith nullable alanları null olarak ayarlar', () {
      final updated = testReport.copyWith(
        description: null,
        reviewedBy: null,
        reviewedAt: null,
      );

      expect(updated.description, isNull);
      expect(updated.reviewedBy, isNull);
      expect(updated.reviewedAt, isNull);
    });

    // ── Tarih parsing testleri ──

    test('tarih parsing Timestamp tipini doğru ayrıştırır', () {
      final map = {'createdAt': Timestamp.fromDate(testDate)};
      final model = ReportModel.fromMap(map);
      expect(model.createdAt, testDate);
    });

    test('tarih parsing DateTime tipini doğru ayrıştırır', () {
      final map = {'createdAt': testDate};
      final model = ReportModel.fromMap(map);
      expect(model.createdAt, testDate);
    });

    test('tarih parsing String tipini doğru ayrıştırır', () {
      final map = {'createdAt': '2026-09-01T12:00:00.000'};
      final model = ReportModel.fromMap(map);
      expect(model.createdAt, isNotNull);
      expect(model.createdAt!.year, 2026);
    });

    test('tarih parsing int tipini doğru ayrıştırır', () {
      final millis = testDate.millisecondsSinceEpoch;
      final map = {'createdAt': millis};
      final model = ReportModel.fromMap(map);
      expect(model.createdAt, isNotNull);
    });

    test('tarih parsing null için null döner', () {
      final map = <String, dynamic>{'createdAt': null};
      final model = ReportModel.fromMap(map);
      expect(model.createdAt, isNull);
    });
  });

  // ── Enum parsing testleri ──

  group('ReportReason Testleri', () {
    test('tüm geçerli code değerleri doğru enum döner', () {
      expect(ReportReason.fromString('inappropriate_content'), ReportReason.inappropriateContent);
      expect(ReportReason.fromString('spam_misleading'), ReportReason.spamMisleading);
      expect(ReportReason.fromString('hate_speech'), ReportReason.hateSpeech);
      expect(ReportReason.fromString('harassment'), ReportReason.harassment);
      expect(ReportReason.fromString('copyright_violation'), ReportReason.copyrightViolation);
      expect(ReportReason.fromString('other'), ReportReason.other);
    });

    test('eski Türkçe label değerleri backward compatibility için doğru enum döner', () {
      expect(ReportReason.fromString('Uygunsuz içerik'), ReportReason.inappropriateContent);
      expect(ReportReason.fromString('Spam veya yanıltıcı'), ReportReason.spamMisleading);
      expect(ReportReason.fromString('Nefret söylemi'), ReportReason.hateSpeech);
      expect(ReportReason.fromString('Taciz veya zorbalık'), ReportReason.harassment);
      expect(ReportReason.fromString('Telif hakkı ihlali'), ReportReason.copyrightViolation);
      expect(ReportReason.fromString('Diğer'), ReportReason.other);
    });

    test('bilinmeyen veya null değer other döner', () {
      expect(ReportReason.fromString('unknown'), ReportReason.other);
      expect(ReportReason.fromString(null), ReportReason.other);
      expect(ReportReason.fromString(''), ReportReason.other);
    });

    test('her enum değeri benzersiz value ve dolu label içerir', () {
      final values = ReportReason.values.map((e) => e.value).toSet();
      expect(values.length, ReportReason.values.length);
      for (final reason in ReportReason.values) {
        expect(reason.value.isNotEmpty, isTrue);
        expect(reason.label.isNotEmpty, isTrue);
      }
    });
  });

  group('ReportTargetType Testleri', () {
    test('tüm geçerli değerler doğru enum döner', () {
      expect(ReportTargetType.fromString('post'), ReportTargetType.post);
      expect(ReportTargetType.fromString('material'), ReportTargetType.material);
      expect(ReportTargetType.fromString('event'), ReportTargetType.event);
      expect(ReportTargetType.fromString('user'), ReportTargetType.user);
    });

    test('bilinmeyen değer varsayılan post döner', () {
      expect(ReportTargetType.fromString('unknown'), ReportTargetType.post);
      expect(ReportTargetType.fromString(null), ReportTargetType.post);
    });
  });

  group('ReportStatus Testleri', () {
    test('tüm geçerli değerler doğru enum döner', () {
      expect(ReportStatus.fromString('open'), ReportStatus.open);
      expect(ReportStatus.fromString('reviewed'), ReportStatus.reviewed);
      expect(ReportStatus.fromString('resolved'), ReportStatus.resolved);
      expect(ReportStatus.fromString('rejected'), ReportStatus.rejected);
    });

    test('bilinmeyen değer varsayılan open döner', () {
      expect(ReportStatus.fromString('unknown'), ReportStatus.open);
      expect(ReportStatus.fromString(null), ReportStatus.open);
    });
  });
}

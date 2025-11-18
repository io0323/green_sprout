import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/features/wearable/domain/entities/wearable_analysis_result.dart';

/// WearableAnalysisResultのテスト
void main() {
  group('WearableAnalysisResult', () {
    test('fromJsonで正しく作成される', () {
      final json = {
        'growthStage': '若葉',
        'healthStatus': '健康',
        'confidence': 0.85,
        'timestamp': '2024-12-23T10:00:00.000Z',
      };

      final result = WearableAnalysisResult.fromJson(json);

      expect(result.growthStage, '若葉');
      expect(result.healthStatus, '健康');
      expect(result.confidence, 0.85);
      expect(result.timestamp, DateTime.parse('2024-12-23T10:00:00.000Z'));
    });

    test('toJsonで正しく変換される', () {
      final result = WearableAnalysisResult(
        growthStage: '成葉',
        healthStatus: '軽微な損傷',
        confidence: 0.75,
        timestamp: DateTime.parse('2024-12-23T10:00:00.000Z'),
      );

      final json = result.toJson();

      expect(json['growthStage'], '成葉');
      expect(json['healthStatus'], '軽微な損傷');
      expect(json['confidence'], 0.75);
      expect(json['timestamp'], '2024-12-23T10:00:00.000Z');
    });

    test('fromJsonとtoJsonの往復変換が正しく動作する', () {
      final original = WearableAnalysisResult(
        growthStage: '芽',
        healthStatus: '健康',
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      final json = original.toJson();
      final restored = WearableAnalysisResult.fromJson(json);

      expect(restored.growthStage, original.growthStage);
      expect(restored.healthStatus, original.healthStatus);
      expect(restored.confidence, original.confidence);
      expect(restored.timestamp, original.timestamp);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/features/tea_analysis/domain/entities/analysis_result.dart';

/// AnalysisResultエンティティのテスト
void main() {
  group('AnalysisResult', () {
    test('should create AnalysisResult with all properties', () {
      // Arrange
      const growthStage = '若葉';
      const healthStatus = '健康';
      const confidence = 0.95;

      // Act
      const result = AnalysisResult(
        growthStage: growthStage,
        healthStatus: healthStatus,
        confidence: confidence,
      );

      // Assert
      expect(result.growthStage, growthStage);
      expect(result.healthStatus, healthStatus);
      expect(result.confidence, confidence);
    });

    test('should support equality', () {
      // Arrange
      const result1 = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '健康',
        confidence: 0.95,
      );
      const result2 = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '健康',
        confidence: 0.95,
      );
      const result3 = AnalysisResult(
        growthStage: '成葉',
        healthStatus: '健康',
        confidence: 0.95,
      );

      // Assert
      expect(result1, equals(result2));
      expect(result1, isNot(equals(result3)));
    });

    test('should support toString', () {
      // Arrange
      const result = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '健康',
        confidence: 0.95,
      );

      // Act
      final stringRepresentation = result.toString();

      // Assert
      expect(stringRepresentation, contains('若葉'));
      expect(stringRepresentation, contains('健康'));
      expect(stringRepresentation, contains('0.95'));
    });

    test('should support isHighConfidence property', () {
      // Arrange
      const highConfidenceResult = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '健康',
        confidence: 0.9,
      );
      const lowConfidenceResult = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '健康',
        confidence: 0.7,
      );

      // Assert
      expect(highConfidenceResult.isHighConfidence, true);
      expect(lowConfidenceResult.isHighConfidence, false);
    });

    test('should support isHealthy property', () {
      // Arrange
      const healthyResult = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '健康',
        confidence: 0.9,
      );
      const unhealthyResult = AnalysisResult(
        growthStage: '若葉',
        healthStatus: '病気',
        confidence: 0.9,
      );

      // Assert
      expect(healthyResult.isHealthy, true);
      expect(unhealthyResult.isHealthy, false);
    });
  });
}

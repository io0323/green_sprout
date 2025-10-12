import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:tea_garden_ai/features/tea_analysis/data/datasources/analysis_local_datasource_impl.dart';
import 'package:tea_garden_ai/features/tea_analysis/domain/entities/analysis_result.dart';
import 'package:tea_garden_ai/core/errors/failures.dart';

/// AI解析データソースのテスト
void main() {
  group('AnalysisLocalDataSourceImpl', () {
    late AnalysisLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = AnalysisLocalDataSourceImpl();
    });

    group('analyzeImage', () {
      test('should return AnalysisResult when image analysis succeeds', () async {
        // Arrange
        final imageFile = File('test_image.jpg');

        // Act
        final result = await dataSource.analyzeImage(imageFile);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (analysisResult) {
            expect(analysisResult, isA<AnalysisResult>());
            expect(analysisResult.growthStage, isIn(['芽', '若葉', '成葉', '老葉']));
            expect(analysisResult.healthStatus, isIn(['健康', '軽微な損傷', '損傷', '病気']));
            expect(analysisResult.confidence, greaterThanOrEqualTo(0.85));
            expect(analysisResult.confidence, lessThanOrEqualTo(1.0));
          },
        );
      });

      test('should simulate analysis delay', () async {
        // Arrange
        final imageFile = File('test_image.jpg');
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.analyzeImage(imageFile);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(2000));
      });
    });

    group('loadModel', () {
      test('should return success when model loads', () async {
        // Act
        final result = await dataSource.loadModel();

        // Assert
        expect(result.isRight(), true);
        expect(dataSource.isModelLoaded, true);
      });

      test('should simulate loading delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.loadModel();

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });
    });

    group('isModelLoaded', () {
      test('should return false initially', () {
        // Assert
        expect(dataSource.isModelLoaded, false);
      });

      test('should return true after loading model', () async {
        // Act
        await dataSource.loadModel();

        // Assert
        expect(dataSource.isModelLoaded, true);
      });
    });
  });
}

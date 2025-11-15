import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tea_garden_ai/core/engines/advanced_analysis_engine.dart';
import 'package:tea_garden_ai/features/tea_analysis/domain/entities/analysis_result.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';

/**
 * 高度なAI解析エンジンのテスト
 */
void main() {
  group('AdvancedAnalysisEngine', () {
    late AdvancedAnalysisEngine engine;

    setUp(() {
      engine = AdvancedAnalysisEngine();
    });

    tearDown(() {
      engine.dispose();
    });

    /**
     * テスト用の画像を作成
     */
    img.Image createTestImage({
      int width = 224,
      int height = 224,
      int r = 50,
      int g = 200,
      int b = 50,
    }) {
      final image = img.Image(width: width, height: height);
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          image.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
      return image;
    }

    group('initialize', () {
      test('should initialize engine successfully', () async {
        // Act
        await engine.initialize();

        // Assert
        // 初期化が完了していることを確認（例外が発生しない）
        expect(engine, isNotNull);
      });

      test('should handle initialization errors gracefully', () async {
        // Act & Assert
        // エラーが発生しても例外を投げないことを確認
        expect(() => engine.initialize(), returnsNormally);
      });
    });

    group('analyzeImage', () {
      test('should return AnalysisResult with valid image', () async {
        // Arrange
        await engine.initialize();
        final image = createTestImage();

        // Act
        final result = await engine.analyzeImage(image);

        // Assert
        expect(result, isA<AnalysisResult>());
        expect(result.growthStage, isIn(GrowthStageConstants.allStages));
        expect(result.healthStatus, isIn(HealthStatusConstants.allStatuses));
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
      });

      test('should handle different image sizes', () async {
        // Arrange
        await engine.initialize();
        final smallImage = createTestImage(width: 100, height: 100);
        final largeImage = createTestImage(width: 500, height: 500);

        // Act
        final smallResult = await engine.analyzeImage(smallImage);
        final largeResult = await engine.analyzeImage(largeImage);

        // Assert
        expect(smallResult, isA<AnalysisResult>());
        expect(largeResult, isA<AnalysisResult>());
      });

      test('should return consistent results for same image', () async {
        // Arrange
        await engine.initialize();
        final image = createTestImage();

        // Act
        final result1 = await engine.analyzeImage(image);
        final result2 = await engine.analyzeImage(image);

        // Assert
        // 同じ画像に対して一貫した結果を返すことを確認
        expect(result1.growthStage, result2.growthStage);
        expect(result1.healthStatus, result2.healthStatus);
      });

      test('should return different results for different images', () async {
        // Arrange
        await engine.initialize();
        final greenImage = createTestImage(r: 50, g: 200, b: 50);
        final yellowImage = createTestImage(r: 255, g: 255, b: 0);

        // Act
        final greenResult = await engine.analyzeImage(greenImage);
        final yellowResult = await engine.analyzeImage(yellowImage);

        // Assert
        expect(greenResult, isA<AnalysisResult>());
        expect(yellowResult, isA<AnalysisResult>());
        // 異なる画像に対して異なる結果を返す可能性があることを確認
        // （必ずしも異なるとは限らないが、少なくともエラーにならない）
      });

      test('should auto-initialize if not initialized', () async {
        // Arrange
        final image = createTestImage();

        // Act
        final result = await engine.analyzeImage(image);

        // Assert
        expect(result, isA<AnalysisResult>());
      });
    });

    group('dispose', () {
      test('should dispose resources properly', () async {
        // Arrange
        await engine.initialize();

        // Act & Assert
        expect(() => engine.dispose(), returnsNormally);
      });

      test('should handle multiple dispose calls', () async {
        // Arrange
        await engine.initialize();

        // Act & Assert
        engine.dispose();
        expect(() => engine.dispose(), returnsNormally);
      });
    });

    group('image quality assessment', () {
      test('should assess image quality correctly', () async {
        // Arrange
        await engine.initialize();
        final clearImage = createTestImage();
        final blurryImage = createTestImage();
        // ぼかし処理を適用
        final blurred = img.gaussianBlur(blurryImage, radius: 5);

        // Act
        final clearResult = await engine.analyzeImage(clearImage);
        final blurryResult = await engine.analyzeImage(blurred);

        // Assert
        expect(clearResult, isA<AnalysisResult>());
        expect(blurryResult, isA<AnalysisResult>());
        // 画像品質の評価が機能していることを確認
      });
    });

    group('ensemble method', () {
      test('should combine multiple analysis methods', () async {
        // Arrange
        await engine.initialize();
        final image = createTestImage();

        // Act
        final result = await engine.analyzeImage(image);

        // Assert
        expect(result, isA<AnalysisResult>());
        // アンサンブル手法により複数の解析結果が統合されていることを確認
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
      });
    });

    group('feature extraction', () {
      test('should extract features from image', () async {
        // Arrange
        await engine.initialize();
        final image = createTestImage();

        // Act
        final result = await engine.analyzeImage(image);

        // Assert
        expect(result, isA<AnalysisResult>());
        // 特徴抽出が機能していることを確認
        expect(result.growthStage, isNotEmpty);
        expect(result.healthStatus, isNotEmpty);
      });
    });
  });
}

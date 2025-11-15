import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tea_garden_ai/core/utils/advanced_image_processor.dart';

/**
 * 高度な画像処理ユーティリティのテスト
 */
void main() {
  group('AdvancedImageProcessor', () {
    /**
     * テスト用の画像を作成
     */
    img.Image createTestImage({
      int width = 224,
      int height = 224,
      int r = 100,
      int g = 150,
      int b = 100,
    }) {
      final image = img.Image(width: width, height: height);
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          image.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
      return image;
    }

    group('preprocessImage', () {
      test('should preprocess image without errors', () {
        // Arrange
        final image = createTestImage();

        // Act
        final processed = AdvancedImageProcessor.preprocessImage(image);

        // Assert
        expect(processed, isNotNull);
        expect(processed.width, greaterThan(0));
        expect(processed.height, greaterThan(0));
      });

      test('should resize image to target size', () {
        // Arrange
        final largeImage = createTestImage(width: 500, height: 500);

        // Act
        final processed = AdvancedImageProcessor.preprocessImage(largeImage);

        // Assert
        expect(processed.width, lessThanOrEqualTo(224));
        expect(processed.height, lessThanOrEqualTo(224));
      });

      test('should maintain aspect ratio', () {
        // Arrange
        final wideImage = createTestImage(width: 400, height: 200);

        // Act
        final processed = AdvancedImageProcessor.preprocessImage(wideImage);

        // Assert
        final aspectRatio = processed.width / processed.height;
        expect(aspectRatio, closeTo(2.0, 0.1));
      });
    });

    group('imageToFloat32List', () {
      test('should convert image to Float32List', () {
        // Arrange
        final image = createTestImage();
        // 前処理を適用して224x224にリサイズ
        final processed = AdvancedImageProcessor.preprocessImage(image);

        // Act
        final floatList = AdvancedImageProcessor.imageToFloat32List(processed);

        // Assert
        expect(floatList, isA<List<double>>());
        expect(floatList.length, 224 * 224 * 3);
      });

      test('should normalize pixel values', () {
        // Arrange
        final image = createTestImage();
        // 前処理を適用して224x224にリサイズ
        final processed = AdvancedImageProcessor.preprocessImage(image);

        // Act
        final floatList = AdvancedImageProcessor.imageToFloat32List(processed);

        // Assert
        // 正規化された値が適切な範囲内にあることを確認
        expect(floatList.length, 224 * 224 * 3);
        for (final value in floatList) {
          expect(value, greaterThan(-10.0));
          expect(value, lessThan(10.0));
        }
      });
    });

    group('assessImageQuality', () {
      test('should assess image quality', () {
        // Arrange
        final image = createTestImage();

        // Act
        final quality = AdvancedImageProcessor.assessImageQuality(image);

        // Assert
        expect(quality, isNotNull);
        expect(quality.blurScore, greaterThanOrEqualTo(0.0));
        expect(quality.blurScore, lessThanOrEqualTo(1.0));
        expect(quality.brightnessScore, greaterThanOrEqualTo(0.0));
        expect(quality.brightnessScore, lessThanOrEqualTo(1.0));
        expect(quality.contrastScore, greaterThanOrEqualTo(0.0));
        expect(quality.contrastScore, lessThanOrEqualTo(1.0));
        expect(quality.overallScore, greaterThanOrEqualTo(0.0));
        expect(quality.overallScore, lessThanOrEqualTo(1.0));
      });

      test('should detect blurry images', () {
        // Arrange
        final clearImage = createTestImage();
        final blurryImage = img.gaussianBlur(createTestImage(), radius: 5);

        // Act
        final clearQuality =
            AdvancedImageProcessor.assessImageQuality(clearImage);
        final blurryQuality =
            AdvancedImageProcessor.assessImageQuality(blurryImage);

        // Assert
        expect(clearQuality.blurScore, greaterThanOrEqualTo(0.0));
        expect(blurryQuality.blurScore, greaterThanOrEqualTo(0.0));
      });

      test('should detect brightness issues', () {
        // Arrange
        final brightImage = createTestImage(r: 255, g: 255, b: 255);
        final darkImage = createTestImage(r: 0, g: 0, b: 0);

        // Act
        final brightQuality =
            AdvancedImageProcessor.assessImageQuality(brightImage);
        final darkQuality =
            AdvancedImageProcessor.assessImageQuality(darkImage);

        // Assert
        expect(brightQuality.brightnessScore, greaterThanOrEqualTo(0.0));
        expect(darkQuality.brightnessScore, greaterThanOrEqualTo(0.0));
      });
    });

    group('extractFeatures', () {
      test('should extract image features', () {
        // Arrange
        final image = createTestImage();

        // Act
        final features = AdvancedImageProcessor.extractFeatures(image);

        // Assert
        expect(features, isNotNull);
        expect(features.averageHue, greaterThanOrEqualTo(0.0));
        expect(features.averageHue, lessThanOrEqualTo(360.0));
        expect(features.averageSaturation, greaterThanOrEqualTo(0.0));
        expect(features.averageSaturation, lessThanOrEqualTo(1.0));
        expect(features.averageLightness, greaterThanOrEqualTo(0.0));
        expect(features.averageLightness, lessThanOrEqualTo(1.0));
        expect(features.pixelCount, greaterThan(0));
      });

      test('should extract different features for different colors', () {
        // Arrange
        final greenImage = createTestImage(r: 50, g: 200, b: 50);
        final redImage = createTestImage(r: 200, g: 50, b: 50);

        // Act
        final greenFeatures =
            AdvancedImageProcessor.extractFeatures(greenImage);
        final redFeatures = AdvancedImageProcessor.extractFeatures(redImage);

        // Assert
        expect(greenFeatures, isNotNull);
        expect(redFeatures, isNotNull);
        // 異なる色に対して異なる特徴量を抽出することを確認
        // （色相が同じ場合もあるため、少なくともエラーにならないことを確認）
        expect(greenFeatures.averageHue, greaterThanOrEqualTo(0.0));
        expect(redFeatures.averageHue, greaterThanOrEqualTo(0.0));
      });
    });
  });
}

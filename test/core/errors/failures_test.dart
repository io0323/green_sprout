import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/errors/failures.dart';

/// エラーハンドリングのテスト
void main() {
  group('Failures', () {
    group('CameraFailure', () {
      test('should create CameraFailure with message', () {
        // Arrange
        const message = 'カメラエラー';

        // Act
        const failure = CameraFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should support equality', () {
        // Arrange
        const failure1 = CameraFailure('エラー1');
        const failure2 = CameraFailure('エラー1');
        const failure3 = CameraFailure('エラー2');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('TFLiteFailure', () {
      test('should create TFLiteFailure with message', () {
        // Arrange
        const message = 'TFLiteエラー';

        // Act
        const failure = TFLiteFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should support equality', () {
        // Arrange
        const failure1 = TFLiteFailure('エラー1');
        const failure2 = TFLiteFailure('エラー1');
        const failure3 = TFLiteFailure('エラー2');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('CacheFailure', () {
      test('should create CacheFailure with message', () {
        // Arrange
        const message = 'キャッシュエラー';

        // Act
        const failure = CacheFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should support equality', () {
        // Arrange
        const failure1 = CacheFailure('エラー1');
        const failure2 = CacheFailure('エラー1');
        const failure3 = CacheFailure('エラー2');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ServerFailure', () {
      test('should create ServerFailure with message', () {
        // Arrange
        const message = 'サーバーエラー';

        // Act
        const failure = ServerFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should support equality', () {
        // Arrange
        const failure1 = ServerFailure('エラー1');
        const failure2 = ServerFailure('エラー1');
        const failure3 = ServerFailure('エラー2');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });
  });
}

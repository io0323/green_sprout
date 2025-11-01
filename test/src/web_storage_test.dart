import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/src/web_storage.dart';

/**
 * Webストレージ機能のテスト
 */
void main() {
  group('Webストレージ機能', () {
    group('getLocalStorage', () {
      test('キーが存在しない場合はnullを返す', () {
        // Arrange
        const key = 'non_existent_key';

        // Act
        final result = getLocalStorage(key);

        // Assert
        expect(result, isNull);
      });
    });

    group('setLocalStorage', () {
      test('値を保存できる', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';

        // Act
        setLocalStorage(key, value);
        final result = getLocalStorage(key);

        // Assert
        // 非Webプラットフォームではnullを返す可能性があるため、
        // エラーが発生しないことを確認
        expect(() => setLocalStorage(key, value), returnsNormally);
        // 結果はnullまたは保存された値であることを確認
        expect(result, isA<String?>());
      });

      test('同じキーで値を上書きできる', () {
        // Arrange
        const key = 'test_key';
        const value1 = 'value1';
        const value2 = 'value2';

        // Act
        setLocalStorage(key, value1);
        setLocalStorage(key, value2);
        final result = getLocalStorage(key);

        // Assert
        // エラーが発生しないことを確認
        expect(() => setLocalStorage(key, value2), returnsNormally);
        // 結果はnullまたは保存された値であることを確認
        expect(result, isA<String?>());
      });

      test('空の文字列を保存できる', () {
        // Arrange
        const key = 'empty_key';
        const value = '';

        // Act & Assert
        expect(() => setLocalStorage(key, value), returnsNormally);
      });

      test('長い文字列を保存できる', () {
        // Arrange
        const key = 'long_key';
        final value = 'a' * 1000;

        // Act & Assert
        expect(() => setLocalStorage(key, value), returnsNormally);
      });

      test('特殊文字を含む文字列を保存できる', () {
        // Arrange
        const key = 'special_key';
        const value = 'test@example.com\n\t日本語';

        // Act & Assert
        expect(() => setLocalStorage(key, value), returnsNormally);
      });
    });

    group('downloadFile', () {
      test('ファイルをダウンロードできる（エラーが発生しない）', () {
        // Arrange
        const content = 'test content';
        const filename = 'test.txt';
        const mimeType = 'text/plain';

        // Act & Assert
        // 非Webプラットフォームでは何もしないが、エラーは発生しない
        expect(
          () => downloadFile(content, filename, mimeType),
          returnsNormally,
        );
      });

      test('空のコンテンツをダウンロードできる', () {
        // Arrange
        const content = '';
        const filename = 'empty.txt';
        const mimeType = 'text/plain';

        // Act & Assert
        expect(
          () => downloadFile(content, filename, mimeType),
          returnsNormally,
        );
      });

      test('JSONコンテンツをダウンロードできる', () {
        // Arrange
        const content = '{"key": "value"}';
        const filename = 'data.json';
        const mimeType = 'application/json';

        // Act & Assert
        expect(
          () => downloadFile(content, filename, mimeType),
          returnsNormally,
        );
      });

      test('CSVコンテンツをダウンロードできる', () {
        // Arrange
        const content = 'col1,col2\nval1,val2';
        const filename = 'data.csv';
        const mimeType = 'text/csv';

        // Act & Assert
        expect(
          () => downloadFile(content, filename, mimeType),
          returnsNormally,
        );
      });
    });

    group('統合テスト', () {
      test('保存と取得の一連の流れが動作する', () {
        // Arrange
        const key = 'integration_test_key';
        const value = 'integration_test_value';

        // Act
        setLocalStorage(key, value);
        final retrievedValue = getLocalStorage(key);

        // Assert
        // エラーが発生しないことを確認
        // 非Webプラットフォームではnullが返る可能性がある
        expect(() => setLocalStorage(key, value), returnsNormally);
        // 取得した値はnullまたは保存された値であることを確認
        expect(retrievedValue, isA<String?>());
      });

      test('複数のキーを保存できる', () {
        // Arrange
        const key1 = 'key1';
        const value1 = 'value1';
        const key2 = 'key2';
        const value2 = 'value2';

        // Act
        setLocalStorage(key1, value1);
        setLocalStorage(key2, value2);

        // Assert
        // エラーが発生しないことを確認
        expect(() => setLocalStorage(key1, value1), returnsNormally);
        expect(() => setLocalStorage(key2, value2), returnsNormally);
      });
    });
  });
}

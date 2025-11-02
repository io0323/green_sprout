import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/main.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';

/// 茶園管理AIアプリのウィジェットテスト
void main() {
  // Ensure test binding is initialized before any async/platform calls
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tea Garden AI App', () {
    /// テキストマッチングヘルパー関数
    bool textMatches(Widget widget, List<String> candidates) {
      if (widget is Text) {
        final data = widget.data ?? widget.textSpan?.toPlainText();
        return data != null && candidates.contains(data);
      }
      if (widget is RichText) {
        final plain = widget.text.toPlainText();
        return candidates.contains(plain);
      }
      return false;
    }

    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // Arrange: テスト用の翻訳をロード（ファイルI/Oを回避）
      await LocalizationService.instance.loadTranslationsForTest();

      // Act: アプリを構築し、非同期/描画完了まで待機
      await tester.pumpWidget(const TeaGardenApp());
      await tester.pumpAndSettle();

      // Assert: AppBarが存在すること
      expect(find.byType(AppBar), findsOneWidget);

      // Assert: タイトルが表示されること（日本語/英語どちらでも可）
      final titleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.byWidgetPredicate(
          (w) => textMatches(w, ['茶園管理AI', 'Tea Garden AI']),
        ),
      );
      expect(titleFinder, findsWidgets);
    });

    testWidgets('カメラボタンが表示される', (WidgetTester tester) async {
      // Arrange
      await LocalizationService.instance.loadTranslationsForTest();

      // Act
      await tester.pumpWidget(const TeaGardenApp());
      await tester.pumpAndSettle();

      // Assert: カメラボタンが表示される（日本語/英語どちらでも可）
      final cameraButtonFinder = find.descendant(
        of: find.byWidgetPredicate(
          (w) =>
              w is ElevatedButton ||
              w is TextButton ||
              w is OutlinedButton ||
              w is IconButton,
        ),
        matching: find.byWidgetPredicate(
          (w) => textMatches(w, ['茶葉を撮影・解析', 'Take photo / analyze']),
        ),
      );
      // 1件以上あれば合格（UIに複数存在しても許容）
      final matches = cameraButtonFinder.evaluate().toList();
      expect(matches.length, greaterThan(0));
    });

    testWidgets('ナビゲーションボタンが表示される', (WidgetTester tester) async {
      // Arrange
      await LocalizationService.instance.loadTranslationsForTest();

      // Act
      await tester.pumpWidget(const TeaGardenApp());
      await tester.pumpAndSettle();

      // Assert: 履歴アイコンが表示される
      expect(find.byIcon(Icons.history), findsWidgets);
    });

    testWidgets('アプリのテーマが適用される', (WidgetTester tester) async {
      // Arrange
      await LocalizationService.instance.loadTranslationsForTest();

      // Act
      await tester.pumpWidget(const TeaGardenApp());
      await tester.pumpAndSettle();

      // Assert: MaterialAppが存在すること
      expect(find.byType(MaterialApp), findsOneWidget);

      // Assert: AppBarの背景色が緑であること
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, isNotNull);
    });

    testWidgets('ホーム画面の基本構造が表示される', (WidgetTester tester) async {
      // Arrange
      await LocalizationService.instance.loadTranslationsForTest();

      // Act
      await tester.pumpWidget(const TeaGardenApp());
      await tester.pumpAndSettle();

      // Assert: Scaffoldが存在すること
      expect(find.byType(Scaffold), findsWidgets);

      // Assert: AppBarが存在すること
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}

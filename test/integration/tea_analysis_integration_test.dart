import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tea_garden_ai/main.dart' as app;

/// 茶葉解析機能の統合テスト
/// 実際のアプリケーションの動作をテスト
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('茶葉解析統合テスト', () {
    testWidgets('アプリ起動とUI表示のテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホーム画面が表示されることを確認
      expect(find.text('茶園管理AI'), findsOneWidget);
      expect(find.text('今日の解析結果'), findsOneWidget);

      // 写真撮影ボタンが表示されることを確認
      expect(find.text('茶葉を撮影・解析'), findsOneWidget);

      // ナビゲーションボタンが表示されることを確認
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('カメラ機能のテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // カメラボタンをタップ
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // カメラ画面が表示されることを確認
      expect(find.text('茶葉を撮影・解析'), findsOneWidget);
    });

    testWidgets('日誌一覧の表示テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 日誌ボタンをタップ
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // 日誌ダイアログが表示されることを確認
      expect(find.text('解析履歴'), findsOneWidget);

      // 閉じるボタンをタップ
      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();

      // ダイアログが閉じられることを確認
      expect(find.text('解析履歴'), findsNothing);
    });

    testWidgets('エラーハンドリングのテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // Find the camera button once and get its center coordinates
      final cameraFinder = find.byIcon(Icons.camera_alt);
      expect(cameraFinder, findsOneWidget,
          reason: 'camera button must be present at test start');
      final Offset cameraCenter = tester.getCenter(cameraFinder);

      // Tap the same screen coordinate multiple times to simulate rapid taps
      for (int i = 0; i < 3; i++) {
        await tester.tapAt(cameraCenter);
        // short wait between taps to simulate rapid user interaction
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // アプリがクラッシュせずに動作し続けることを確認
      expect(find.text('茶園管理AI'), findsOneWidget);
    });

    testWidgets('レスポンシブデザインのテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 画面サイズを変更
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // UIが適切に表示されることを確認
      expect(find.text('茶園管理AI'), findsOneWidget);

      // 元のサイズに戻す
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      // UIが適切に表示されることを確認
      expect(find.text('茶園管理AI'), findsOneWidget);
    });
  });
}

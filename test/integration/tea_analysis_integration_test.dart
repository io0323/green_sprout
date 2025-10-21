import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tea_garden_ai/main.dart' as app;

/**
 * 茶葉解析機能の統合テスト
 * 実際のアプリケーションの動作をテスト
 */
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('茶葉解析統合テスト', () {
    testWidgets('アプリ起動から解析完了までのフロー', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホーム画面が表示されることを確認
      expect(find.text('茶園管理AI'), findsOneWidget);
      expect(find.text('今日の解析結果'), findsOneWidget);

      // 写真撮影ボタンが表示されることを確認
      expect(find.text('茶葉を撮影・解析'), findsOneWidget);

      // 撮影ボタンをタップ
      await tester.tap(find.text('茶葉を撮影・解析'));
      await tester.pumpAndSettle();

      // 解析処理が開始されることを確認
      expect(find.text('データを読み込み中...'), findsOneWidget);

      // 解析完了まで待機
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 成功メッセージが表示されることを確認
      expect(find.text('解析が完了しました！'), findsOneWidget);

      // 新しい解析結果が追加されることを確認
      expect(find.text('新しい解析結果です。茶葉の状態を確認しました。'), findsOneWidget);
    });

    testWidgets('エラーハンドリングのテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 複数回連続で撮影ボタンをタップ
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('茶葉を撮影・解析'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // アプリがクラッシュせずに動作し続けることを確認
      expect(find.text('茶園管理AI'), findsOneWidget);
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
  });
}

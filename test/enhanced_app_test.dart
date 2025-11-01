import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/enhanced_app.dart';

/**
 * 拡張版茶園管理AIアプリのテスト
 */
void main() {
  group('EnhancedTeaGardenApp', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // AppBarが表示されることを確認
      expect(find.byType(AppBar), findsOneWidget);

      // タイトルが表示されることを確認（複数表示される可能性があるため）
      expect(find.text('茶園管理AI - 拡張版'), findsWidgets);
    });

    testWidgets('タブナビゲーションが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // タブが表示されることを確認
      expect(find.byIcon(Icons.dashboard), findsWidgets);
      expect(find.byIcon(Icons.camera_alt), findsWidgets);
      expect(find.byIcon(Icons.bar_chart), findsWidgets);
      expect(find.byIcon(Icons.download), findsWidgets);
      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('ダッシュボードタブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // ダッシュボードタブのコンテンツが表示されることを確認
      expect(find.text('茶園管理AI - 拡張版'), findsWidgets);

      // 統計カードが表示されることを確認
      expect(find.text('総解析回数'), findsWidgets);
      expect(find.text('健康率'), findsWidgets);
      expect(find.text('今日の解析'), findsWidgets);
      expect(find.text('平均信頼度'), findsWidgets);
    });

    testWidgets('解析タブで解析ボタンが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // 解析タブをタップ
      final analysisTab = find.byIcon(Icons.camera_alt).first;
      await tester.tap(analysisTab);
      await tester.pumpAndSettle();

      // 解析ボタンが表示されることを確認
      expect(find.text('茶葉を撮影・解析'), findsWidgets);
    });

    testWidgets('解析を実行すると結果が追加される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // 解析タブをタップ
      final analysisTab = find.byIcon(Icons.camera_alt).first;
      await tester.tap(analysisTab);
      await tester.pumpAndSettle();

      // 解析ボタンをタップ
      final analyzeButton = find.text('茶葉を撮影・解析');
      await tester.tap(analyzeButton);

      // ローディング表示を確認
      await tester.pump();
      expect(find.text('AIが茶葉を解析中...'), findsWidgets);

      // 解析が完了するまで待機
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 結果が追加されたことを確認
      expect(find.text('解析履歴'), findsWidgets);

      // SnackBarが表示されることを確認
      expect(find.text('解析が完了しました！'), findsWidgets);
    });

    testWidgets('チャートタブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // チャートタブをタップ
      final chartsTab = find.byIcon(Icons.bar_chart).first;
      await tester.tap(chartsTab);
      await tester.pumpAndSettle();

      // チャートタイトルが表示されることを確認
      expect(find.text('健康状態の推移'), findsWidgets);
      expect(find.text('成長段階の分布'), findsWidgets);
    });

    testWidgets('エクスポートタブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // エクスポートタブをタップ
      final exportTab = find.byIcon(Icons.download).first;
      await tester.tap(exportTab);
      await tester.pumpAndSettle();

      // エクスポートセクションが表示されることを確認
      expect(find.text('データエクスポート'), findsWidgets);
      expect(find.text('CSV'), findsWidgets);
      expect(find.text('JSON'), findsWidgets);
      expect(find.text('PDF'), findsWidgets);
    });

    testWidgets('設定タブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // 設定タブをタップ
      final settingsTab = find.byIcon(Icons.settings).first;
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // 設定セクションが表示されることを確認
      expect(find.text('アプリ設定'), findsWidgets);
      expect(find.text('設定を保存'), findsWidgets);
    });

    testWidgets('空の状態が正しく表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // 解析タブをタップ
      final analysisTab = find.byIcon(Icons.camera_alt).first;
      await tester.tap(analysisTab);
      await tester.pumpAndSettle();

      // 空の状態メッセージが表示されることを確認
      expect(find.text('まだ解析結果がありません'), findsWidgets);
    });
  });
}

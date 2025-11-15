import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:tea_garden_ai/enhanced_app.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';
import 'package:tea_garden_ai/core/di/injection_container.dart' as di;

/// 拡張版茶園管理AIアプリのテスト
void main() {
  setUpAll(() async {
    // GetItをリセットしてから初期化
    await GetIt.instance.reset();

    // DIコンテナを初期化（アプリと同じ初期化処理）
    await di.init();

    // テスト用にローカライゼーションサービスを初期化
    await LocalizationService.instance.loadTranslationsForTest();
    LocalizationService.instance.setLanguage('ja');
  });

  tearDownAll(() async {
    // テスト終了後にGetItをリセット
    await GetIt.instance.reset();
  });

  group('EnhancedTeaGardenApp', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      await tester.pumpAndSettle();

      // AppBarが表示されることを確認
      expect(find.byType(AppBar), findsOneWidget);

      // タイトルが表示されることを確認（複数表示される可能性があるため）
      expect(
          find.text(
              LocalizationService.instance.translate('enhanced_app_title')),
          findsWidgets);
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
      expect(
          find.text(
              LocalizationService.instance.translate('enhanced_app_title')),
          findsWidgets);

      // 統計カードが表示されることを確認
      expect(
          find.text(
              LocalizationService.instance.translate('total_analysis_count')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('health_rate')),
          findsWidgets);
      expect(
          find.text(LocalizationService.instance.translate('today_analysis')),
          findsWidgets);
      expect(
          find.text(LocalizationService.instance.translate('avg_confidence')),
          findsWidgets);
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
      expect(find.text(LocalizationService.instance.translate('take_photo')),
          findsWidgets);
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
      final analyzeButton =
          find.text(LocalizationService.instance.translate('take_photo'));
      await tester.tap(analyzeButton);

      // ローディング表示を確認
      await tester.pump();
      expect(find.text(LocalizationService.instance.translate('ai_analyzing')),
          findsWidgets);

      // 解析が完了するまで待機
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 結果が追加されたことを確認
      expect(
          find.text(LocalizationService.instance.translate('analysis_history')),
          findsWidgets);

      // SnackBarが表示されることを確認
      expect(
          find.text(
              LocalizationService.instance.translate('analysis_complete')),
          findsWidgets);
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
      expect(
          find.text(LocalizationService.instance
              .translate('health_status_distribution')),
          findsWidgets);
      expect(
          find.text(LocalizationService.instance
              .translate('growth_stage_distribution')),
          findsWidgets);
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
      expect(find.text(LocalizationService.instance.translate('export')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('csv')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('json')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('pdf')),
          findsWidgets);
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
      expect(find.text(LocalizationService.instance.translate('app_settings')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('save_settings')),
          findsWidgets);
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
      expect(
          find.text(LocalizationService.instance.translate('no_results_yet')),
          findsWidgets);
    });
  });
}

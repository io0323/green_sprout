import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/routing/app_router.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';

/*
 * AppRouter のローカライズ回帰テスト
 * - フォールバック画面が LocalizationService の翻訳を使っていることを担保する
 * - 将来 AppRouter に直書きが戻った場合にCIで検知する
 */
void main() {
  setUp(() async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {
        'router_unknown_route_title': 'TITLE_UNKNOWN',
        'router_unknown_route_message': 'MSG_UNKNOWN: {route}',
        'router_invalid_navigation_title': 'TITLE_INVALID',
        'router_invalid_arguments_message': 'MSG_INVALID: {route} {expected}',
      },
    });
    service.setLanguage('ja');
  });

  testWidgets('unknown route は翻訳キーのタイトル/本文を表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/unknown',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TITLE_UNKNOWN'), findsOneWidget);
    expect(find.textContaining('MSG_UNKNOWN:'), findsOneWidget);
    expect(find.textContaining('/unknown'), findsOneWidget);
  });

  testWidgets('/analysis 引数不正は翻訳キーのタイトル/本文を表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/analysis',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TITLE_INVALID'), findsOneWidget);
    expect(find.textContaining('MSG_INVALID:'), findsOneWidget);
    expect(find.textContaining('/analysis'), findsOneWidget);
    expect(find.textContaining('String (imagePath)'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';
import 'package:tea_garden_ai/core/routing/app_router.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';

/*
 * AppRouter のルート解決テスト
 * - named routes の配線が壊れて実行時クラッシュしないことを回帰防止する
 *
 * 注意:
 * - ここでは Route の生成とフォールバック画面の文言を検証し、DI(sl)が必要な
 *   画面は build しない（builder 実行を避ける）ことでテストを安定させる。
 */
void main() {
  setUp(() async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {
        'router_invalid_navigation_title': '画面遷移に失敗しました',
        'router_invalid_arguments_message': '引数が不正です: {route}（期待: {expected}）',
      },
    });
    service.setLanguage('ja');
  });

  test('unknown route はフォールバック画面の Route を返す', () {
    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: '/unknown'),
    );
    expect(route, isA<MaterialPageRoute<void>>());
    expect(route.settings.name, '/unknown');
  });

  testWidgets('/analysis の引数が不正な場合はフォールバック画面を表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: RouteNames.analysis,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('画面遷移に失敗しました'), findsOneWidget);
    expect(find.textContaining('Invalid arguments for'), findsOneWidget);
    expect(find.textContaining('expected: String (imagePath)'), findsOneWidget);
  });

  test('known routes は Route を生成できる（builderは実行しない）', () {
    final cameraRoute = AppRouter.onGenerateRoute(
      const RouteSettings(name: RouteNames.camera),
    );
    expect(cameraRoute, isA<MaterialPageRoute<void>>());
    expect(cameraRoute.settings.name, RouteNames.camera);

    final logsRoute = AppRouter.onGenerateRoute(
      const RouteSettings(name: RouteNames.logs),
    );
    expect(logsRoute, isA<MaterialPageRoute<void>>());
    expect(logsRoute.settings.name, RouteNames.logs);

    final analysisRoute = AppRouter.onGenerateRoute(
      const RouteSettings(name: RouteNames.analysis, arguments: 'dummy.jpg'),
    );
    expect(analysisRoute, isA<MaterialPageRoute<void>>());
    expect(analysisRoute.settings.name, RouteNames.analysis);
  });
}

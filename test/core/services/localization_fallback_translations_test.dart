import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';

/*
 * LocalizationService のフォールバック翻訳（en/ja）の回帰テスト
 * - assets/translations/translations.json が読めない状況でもUI文言が壊れないことを担保する
 * - 重要キーが key 文字列のまま露出しないことを担保する
 */
void main() {
  test('デフォルト（フォールバック）翻訳で en の router_* が取得できる', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest(); // null => 内蔵フォールバックを使用

    service.setLanguage('en');
    expect(
      service.translate('router_unknown_route_title'),
      'Page not found',
    );

    final msg = service.translate(
      'router_invalid_arguments_message',
      params: {
        'route': RouteNames.analysis,
        'expected': 'String (imagePath)',
      },
    );
    expect(msg.contains(RouteNames.analysis), isTrue);
    expect(msg.contains('String (imagePath)'), isTrue);
  });

  test('デフォルト（フォールバック）翻訳で ja の advanced_analysis* が取得できる', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest(); // null => 内蔵フォールバックを使用

    service.setLanguage('ja');
    expect(service.translate('advanced_analysis'), '高度な分析');
    expect(
      service.translate('run_advanced_analysis'),
      '高度な分析を実行',
    );
  });

  test('フォールバックに無いキーは key を返す（en）', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest();

    service.setLanguage('en');
    expect(service.translate('nonexistent_key'), 'nonexistent_key');
  });
}

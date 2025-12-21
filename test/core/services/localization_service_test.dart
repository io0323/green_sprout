import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';

/*
 * LocalizationService の回帰テスト
 * - 翻訳のフォールバック挙動（現言語→ja→key）を担保する
 * - パラメータ置換の挙動を担保する
 * - 翻訳データの型が崩れてもクラッシュせず key を返すことを担保する
 */
void main() {
  test('現言語に存在するキーを返す', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {'hello': 'こんにちは'},
      'en': {'hello': 'Hello'},
    });

    service.setLanguage('en');
    expect(service.translate('hello'), 'Hello');
  });

  test('現言語に無い場合は ja をフォールバックする', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {'only_ja': '日本語のみ'},
      'en': {},
    });

    service.setLanguage('en');
    expect(service.translate('only_ja'), '日本語のみ');
  });

  test('ja にも無い場合は key を返す', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {},
      'en': {},
    });

    service.setLanguage('en');
    expect(service.translate('missing_key'), 'missing_key');
  });

  test('params を置換できる', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {'greet': 'こんにちは {name} さん'},
    });

    service.setLanguage('ja');
    expect(
      service.translate('greet', params: {'name': '太郎'}),
      'こんにちは 太郎 さん',
    );
  });

  test('翻訳データの型が崩れていてもクラッシュせず key を返す', () async {
    final service = LocalizationService.instance;
    await service.loadTranslationsForTest({
      'ja': {},
      'en': 'oops',
    });

    // 'en' は不正フォーマットなので正規化で取り込まれず、言語も切り替わらない
    expect(service.availableLanguages.contains('en'), isFalse);
    expect(service.translate('any_key'), 'any_key');
  });
}

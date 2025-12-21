import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/*
 * translations.json の整合性テスト
 * - en/ja のキー差分（追加漏れ）をCIで検知する
 * - 追加したキーは必ず両言語に入れる運用を担保する
 */
void main() {
  test('translations.json の en/ja でキーが一致する', () {
    final file = File('assets/translations/translations.json');
    final contents = file.readAsStringSync();
    final decoded = json.decode(contents) as Map<String, dynamic>;

    final en = decoded['en'] as Map<String, dynamic>;
    final ja = decoded['ja'] as Map<String, dynamic>;

    final enKeys = en.keys.toSet();
    final jaKeys = ja.keys.toSet();

    final missingInJa = enKeys.difference(jaKeys).toList()..sort();
    final missingInEn = jaKeys.difference(enKeys).toList()..sort();

    expect(
      missingInJa,
      isEmpty,
      reason: 'ja に不足しているキー: $missingInJa',
    );
    expect(
      missingInEn,
      isEmpty,
      reason: 'en に不足しているキー: $missingInEn',
    );
  });
}

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

  test('translations.json の en/ja でプレースホルダ（{...}）が一致する', () {
    final file = File('assets/translations/translations.json');
    final contents = file.readAsStringSync();
    final decoded = json.decode(contents) as Map<String, dynamic>;

    final en = decoded['en'] as Map<String, dynamic>;
    final ja = decoded['ja'] as Map<String, dynamic>;

    final placeholderRegExp = RegExp(r'\{([a-zA-Z0-9_]+)\}');

    final mismatches = <String, Map<String, List<String>>>{};

    for (final key in en.keys) {
      final enValue = en[key];
      final jaValue = ja[key];
      if (enValue is! String || jaValue is! String) {
        // 想定外の型はプレースホルダ比較対象外
        continue;
      }

      final enPlaceholders = placeholderRegExp
          .allMatches(enValue)
          .map((m) => m.group(1)!)
          .toSet()
          .toList()
        ..sort();
      final jaPlaceholders = placeholderRegExp
          .allMatches(jaValue)
          .map((m) => m.group(1)!)
          .toSet()
          .toList()
        ..sort();

      if (enPlaceholders.join(',') != jaPlaceholders.join(',')) {
        mismatches[key] = {
          'en': enPlaceholders,
          'ja': jaPlaceholders,
        };
      }
    }

    expect(
      mismatches,
      isEmpty,
      reason: 'プレースホルダ不一致: $mismatches',
    );
  });
}

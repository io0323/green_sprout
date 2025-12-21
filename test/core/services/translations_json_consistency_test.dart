import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/*
 * translations.json の整合性テスト
 * - en/ja のキー差分（追加漏れ）をCIで検知する
 * - 追加したキーは必ず両言語に入れる運用を担保する
 */
void main() {
  test('translations.json の en/ja がMapで、値がすべてStringである', () {
    final file = File('assets/translations/translations.json');
    final contents = file.readAsStringSync();
    final decoded = json.decode(contents) as Map<String, dynamic>;

    expect(decoded.containsKey('en'), isTrue);
    expect(decoded.containsKey('ja'), isTrue);

    final en = decoded['en'];
    final ja = decoded['ja'];

    expect(en, isA<Map<String, dynamic>>());
    expect(ja, isA<Map<String, dynamic>>());

    final enMap = en as Map<String, dynamic>;
    final jaMap = ja as Map<String, dynamic>;

    final nonStringValues = <String, List<String>>{
      'en': [],
      'ja': [],
    };

    for (final entry in enMap.entries) {
      if (entry.value is! String) {
        nonStringValues['en']!.add(entry.key);
      }
    }
    for (final entry in jaMap.entries) {
      if (entry.value is! String) {
        nonStringValues['ja']!.add(entry.key);
      }
    }

    nonStringValues['en']!.sort();
    nonStringValues['ja']!.sort();

    expect(
      nonStringValues['en'],
      isEmpty,
      reason: 'en の value が String ではないキー: ${nonStringValues['en']}',
    );
    expect(
      nonStringValues['ja'],
      isEmpty,
      reason: 'ja の value が String ではないキー: ${nonStringValues['ja']}',
    );
  });

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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/main.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';

void main() {
  testWidgets('Tea Garden AI app smoke test', (WidgetTester tester) async {
    // 翻訳をロード（main() と同等の前処理）
    await LocalizationService.instance.loadTranslations();

    // アプリを構築し、非同期/描画完了まで待機
    await tester.pumpWidget(const TeaGardenApp());
    await tester.pumpAndSettle();

    // Text / RichText 双方に対応したテキスト一致ヘルパー
    bool textMatches(Widget widget, List<String> candidates) {
      if (widget is Text) {
        final data = widget.data ?? widget.textSpan?.toPlainText();
        return data != null && candidates.contains(data);
      }
      if (widget is RichText) {
        final plain = widget.text.toPlainText();
        return candidates.contains(plain);
      }
      return false;
    }

    // タイトル（日本語/英語どちらでも可） - AppBar 配下に限定
    final titleFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.byWidgetPredicate(
        (w) => textMatches(w, ['茶園管理AI', 'Tea Garden AI']),
      ),
    );
    expect(titleFinder, findsWidgets);

    // カメラボタン（日本語/英語どちらでも可） - 一般的なボタン配下に限定
    final cameraButtonFinder = find.descendant(
      of: find.byWidgetPredicate(
        (w) =>
            w is ElevatedButton ||
            w is TextButton ||
            w is OutlinedButton ||
            w is IconButton,
      ),
      matching: find.byWidgetPredicate(
        (w) => textMatches(w, ['茶葉を撮影・解析', 'Take photo / analyze']),
      ),
    );
    // 1件以上あれば合格（UIに複数存在しても許容）
    final matches = cameraButtonFinder.evaluate().toList();
    expect(matches.length, greaterThan(0));

    // AppBar が存在すること
    expect(find.byType(AppBar), findsOneWidget);
  });
}

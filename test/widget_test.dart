import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/main.dart';

void main() {
  testWidgets('Tea Garden AI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TeaGardenApp());

    // Verify that our app title is displayed (accept JP or EN).
    final titleFinder = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        return widget.data == '茶園管理AI' || widget.data == 'Tea Garden AI';
      }
      return false;
    });
    expect(titleFinder, findsOneWidget);

    // Verify that the camera button is present (accept JP or EN).
    final cameraButtonFinder = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        return widget.data == '茶葉を撮影・解析' ||
            widget.data == 'Take photo / analyze';
      }
      return false;
    });
    expect(cameraButtonFinder, findsOneWidget);

    // Verify that the app bar is present.
    expect(find.byType(AppBar), findsOneWidget);
  });
}

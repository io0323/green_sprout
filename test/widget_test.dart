import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/main.dart';

void main() {
  testWidgets('Tea Garden AI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TeaGardenApp());

    // Verify that our app title is displayed.
    expect(find.text('茶園管理AI'), findsOneWidget);

    // Verify that the camera button is present.
    expect(find.text('茶葉を撮影・解析'), findsOneWidget);

    // Verify that the app bar is present.
    expect(find.byType(AppBar), findsOneWidget);
  });
}

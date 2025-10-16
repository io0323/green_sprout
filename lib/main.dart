import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'features/tea_analysis/presentation/pages/web_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Webプラットフォームの場合は簡素化された初期化
  if (kIsWeb) {
    runApp(const TeaGardenApp());
  } else {
    // モバイルプラットフォームの場合は通常の初期化
    try {
      await _initializeMobileApp();
      runApp(const TeaGardenApp());
    } catch (e) {
      // エラーが発生した場合はフォールバック
      runApp(const TeaGardenApp());
    }
  }
}

Future<void> _initializeMobileApp() async {
  // モバイル用の依存性注入初期化
  // 現在はWeb対応のため簡素化
}

class TeaGardenApp extends StatelessWidget {
  const TeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: kIsWeb ? const WebHomePage() : const WebHomePage(), // 現在はWeb用のみ
    );
  }
}
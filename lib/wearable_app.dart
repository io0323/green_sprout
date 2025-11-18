import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/services/localization_service.dart';
import 'core/di/injection_container.dart' as di;
import 'core/utils/platform_utils.dart';
import 'features/wearable/presentation/pages/wearable_home_page.dart';

/// ウェアラブルデバイス用のアプリエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DIコンテナの初期化
  try {
    await di.init();
  } catch (e) {
    if (kDebugMode) debugPrint('DI初期化エラー: $e');
  }

  runApp(const WearableTeaGardenApp());
}

/// ウェアラブルデバイス用のアプリ
class WearableTeaGardenApp extends StatelessWidget {
  const WearableTeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isWearable = PlatformUtils.isWearable;

    return MaterialApp(
      title: LocalizationService.instance.translate('app_title'),
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
        // ウェアラブル用の小さなフォントサイズ
        textTheme: isWearable
            ? const TextTheme(
                bodyLarge: TextStyle(fontSize: 12),
                bodyMedium: TextStyle(fontSize: 11),
                bodySmall: TextStyle(fontSize: 10),
              )
            : null,
      ),
      home: const WearableHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

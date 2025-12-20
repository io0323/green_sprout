import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/services/localization_service.dart';
import 'core/utils/platform_utils.dart';
import 'core/utils/app_initialization.dart';
import 'features/tea_analysis/presentation/pages/web_home_page.dart';
import 'wearable_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドラーの設定
  AppInitialization.setupGlobalErrorHandler();

  // 非同期エラーハンドラーの設定とアプリ実行
  await AppInitialization.runWithErrorHandling(() async {
    // 国際化サービスの初期化
    await AppInitialization.initializeLocalization();

    // エラーワジェットの設定（コンストラクタをconstにするためmainに移動）
    AppInitialization.setupErrorWidget();

    // ウェアラブルデバイスの場合は専用アプリを起動
    if (PlatformUtils.isWearable) {
      runApp(const WearableTeaGardenApp());
      return;
    }

    // DIコンテナの初期化（モバイルのみ）
    if (!kIsWeb) {
      await AppInitialization.initializeDependencyInjection();
    }

    runApp(const TeaGardenApp());
  });
}

class TeaGardenApp extends StatefulWidget {
  const TeaGardenApp({super.key});

  @override
  State<TeaGardenApp> createState() => _TeaGardenAppState();
}

class _TeaGardenAppState extends State<TeaGardenApp> {
  void _updateLanguage() {
    setState(() {
      // 言語変更時にアプリを再構築
    });
  }

  @override
  Widget build(BuildContext context) {
    final appDefaults = AppInitialization.getMaterialAppDefaults();
    return MaterialApp(
      title: LocalizationService.instance.translate('app_title'),
      theme: appDefaults.theme,
      darkTheme: appDefaults.darkTheme,
      themeMode: appDefaults.themeMode,
      localizationsDelegates: appDefaults.localizationsDelegates,
      supportedLocales: appDefaults.supportedLocales,
      debugShowCheckedModeBanner: appDefaults.debugShowCheckedModeBanner,
      onGenerateRoute: appDefaults.onGenerateRoute,
      home: kIsWeb
          ? WebHomePage(onLanguageChanged: _updateLanguage)
          : WebHomePage(onLanguageChanged: _updateLanguage),
    );
  }
}

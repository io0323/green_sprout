import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/services/localization_service.dart';
import 'core/theme/tea_garden_theme.dart';
import 'core/utils/platform_utils.dart';
import 'core/utils/app_localizations.dart';
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

    // ウェアラブルデバイスの場合は専用アプリを起動
    if (PlatformUtils.isWearable) {
      runApp(WearableTeaGardenApp());
      return;
    }

    // DIコンテナの初期化（モバイルのみ）
    if (!kIsWeb) {
      await AppInitialization.initializeDependencyInjection();
    }

    runApp(TeaGardenApp());
  });
}

class TeaGardenApp extends StatefulWidget {
  TeaGardenApp({super.key}) {
    /// エラーバウンダリーを一度だけ設定
    /// ウィジェットツリーでエラーが発生した場合に表示されるカスタムエラー画面
    AppInitialization.setupErrorWidget();
  }

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
    return MaterialApp(
      title: LocalizationService.instance.translate('app_title'),
      theme: TeaGardenTheme.lightTheme,
      darkTheme: TeaGardenTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: kIsWeb
          ? WebHomePage(onLanguageChanged: _updateLanguage)
          : WebHomePage(onLanguageChanged: _updateLanguage),
    );
  }
}

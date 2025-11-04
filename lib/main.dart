import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/localization_service.dart';
import 'core/theme/tea_garden_theme.dart';
import 'features/tea_analysis/presentation/pages/web_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 国際化サービスの初期化
  await LocalizationService.instance.loadTranslations();

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
  await di.init();
}

class TeaGardenApp extends StatefulWidget {
  const TeaGardenApp({super.key});

  @override
  State<TeaGardenApp> createState() => _TeaGardenAppState();
}

class _TeaGardenAppState extends State<TeaGardenApp> {
  String _currentLanguage = 'ja';

  @override
  void initState() {
    super.initState();
    _currentLanguage = LocalizationService.instance.currentLanguage;
  }

  void _updateLanguage() {
    setState(() {
      _currentLanguage = LocalizationService.instance.currentLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: LocalizationService.instance.translate('app_title'),
      theme: TeaGardenTheme.lightTheme,
      darkTheme: TeaGardenTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      home: kIsWeb
          ? WebHomePage(onLanguageChanged: _updateLanguage)
          : WebHomePage(onLanguageChanged: _updateLanguage),
    );
  }
}

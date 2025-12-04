import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// アプリケーション全体で使用するローカライゼーション設定
/// MaterialAppのlocalizationsDelegatesとsupportedLocalesを統一管理
class AppLocalizations {
  AppLocalizations._();

  /// MaterialAppで使用するlocalizationsDelegates
  /// すべてのアプリファイルで統一されたローカライゼーション設定を提供
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// MaterialAppで使用するsupportedLocales
  /// アプリケーションでサポートする言語のリスト
  static const List<Locale> supportedLocales = [
    Locale('ja', 'JP'),
    Locale('en', 'US'),
  ];
}

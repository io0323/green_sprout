import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'core/services/localization_service.dart';
import 'core/di/injection_container.dart' as di;
import 'core/utils/platform_utils.dart';
import 'core/utils/app_logger.dart';
import 'features/wearable/presentation/pages/wearable_home_page.dart';

/// ウェアラブルデバイス用のアプリエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// グローバルエラーハンドラーの設定
  /// Flutterフレームワークレベルのエラーをキャッチ
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.debugError(
      'Flutterエラー',
      '${details.exception}\n${details.stack}',
    );
  };

  /// 非同期エラーハンドラーの設定
  /// runZonedGuardedを使用して未処理の非同期エラーをキャッチ
  runZonedGuarded(() async {
    // 国際化サービスの初期化
    try {
      await LocalizationService.instance.loadTranslations();
      AppLogger.debugInfo('国際化サービスの初期化が完了しました');
    } catch (e, stackTrace) {
      AppLogger.debugError('翻訳データ読み込みエラー', e);
      AppLogger.debugError('スタックトレース', stackTrace);
      AppLogger.debugError('エラータイプ', e.runtimeType);
      // エラーが発生してもアプリは起動を続行
      // デフォルトの日本語翻訳が使用される
    }

    // DIコンテナの初期化
    try {
      await di.init();
      AppLogger.debugInfo('DIコンテナの初期化が完了しました');
    } catch (e, stackTrace) {
      AppLogger.debugError('DI初期化エラー', e);
      AppLogger.debugError('スタックトレース', stackTrace);
      AppLogger.debugError('エラータイプ', e.runtimeType);
      // エラーが発生してもアプリは起動を続行
      // ただし、DIに依存する機能は使用できない可能性がある
    }

    runApp(WearableTeaGardenApp());
  }, (error, stack) {
    /// 未処理の非同期エラーをキャッチ
    /// アプリがクラッシュしないようにエラーをログに記録
    AppLogger.debugError('未処理の非同期エラー', error);
    AppLogger.debugError('スタックトレース', stack);
  });
}

/// ウェアラブルデバイス用のアプリ
class WearableTeaGardenApp extends StatelessWidget {
  WearableTeaGardenApp({super.key}) {
    /// エラーバウンダリーを一度だけ設定
    /// ウィジェットツリーでエラーが発生した場合に表示されるカスタムエラー画面
    _setupErrorBuilder();
  }

  /// エラーバウンダリーの設定
  /// ウィジェットツリーでエラーが発生した場合に表示されるカスタムエラー画面
  static void _setupErrorBuilder() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      AppLogger.debugError('ウィジェットエラー', details.exception);
      AppLogger.debugError('スタックトレース', details.stack);

      /// 国際化サービスを使用してエラーメッセージを取得
      /// 初期化前の場合はデフォルトメッセージを使用
      String errorMessage;
      try {
        errorMessage = LocalizationService.instance.translate('error_occurred');
      } catch (e) {
        errorMessage = 'エラーが発生しました';
      }

      return Material(
        child: Container(
          color: Colors.red[50],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[700],
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (kDebugMode)
                Text(
                  details.exception.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    };
  }

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      home: const WearableHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

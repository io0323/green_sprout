import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'core/services/localization_service.dart';
import 'core/services/wearable_device_service.dart';
import 'core/di/injection_container.dart' as di;
import 'core/utils/platform_utils.dart';
import 'core/utils/app_logger.dart';
import 'core/theme/tea_garden_theme.dart';
import 'features/wearable/presentation/pages/wearable_home_page.dart';

/// グローバルなウェアラブルデバイスサービスインスタンス
/// アプリ全体でアクセス可能にするため
WearableDeviceServiceImpl? _globalWearableService;

/// イベントストリームの購読を管理するためのサブスクリプション
StreamSubscription<WearableEvent>? _wearableEventSubscription;

/// グローバルなウェアラブルデバイスサービスインスタンスを取得
/// サービスが初期化されていない場合はnullを返す
WearableDeviceService? getWearableDeviceService() {
  return _globalWearableService;
}

/// ウェアラブルデバイスが接続されているかどうかを確認
/// サービスが初期化されていない場合はfalseを返す
Future<bool> isWearableDeviceConnected() async {
  if (_globalWearableService == null) {
    return false;
  }
  try {
    return await _globalWearableService!.isConnected();
  } catch (e) {
    AppLogger.debugError('ウェアラブルデバイス接続確認エラー', e);
    return false;
  }
}

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

    // ウェアラブルデバイスサービスの初期化
    try {
      _globalWearableService = WearableDeviceServiceImpl();

      // イベントストリームを監視して接続状態の変化を処理
      _wearableEventSubscription = _globalWearableService!.eventStream.listen(
        (event) {
          switch (event.type) {
            case WearableEventType.connected:
              AppLogger.debugInfo('ウェアラブルデバイスが接続されました');
              break;
            case WearableEventType.disconnected:
              AppLogger.debugInfo('ウェアラブルデバイスが切断されました');
              break;
            case WearableEventType.dataReceived:
              AppLogger.debugInfo('ウェアラブルデバイスからデータを受信しました');
              if (event.data != null) {
                AppLogger.debugInfo('受信データ', event.data.toString());
              }
              break;
            case WearableEventType.error:
              AppLogger.debugError(
                'ウェアラブルデバイスエラー',
                event.error ?? '不明なエラー',
              );
              break;
          }
        },
        onError: (error) {
          AppLogger.debugError('ウェアラブルデバイスイベントストリームエラー', error);
        },
      );

      // 接続状態を確認（非ブロッキング）
      _globalWearableService!.isConnected().then((isConnected) {
        if (isConnected) {
          AppLogger.debugInfo('ウェアラブルデバイスが接続されています');
        } else {
          AppLogger.debugInfo('ウェアラブルデバイスは接続されていません');
        }
      }).catchError((error) {
        AppLogger.debugError('ウェアラブルデバイス接続確認エラー', error);
      });

      AppLogger.debugInfo('ウェアラブルデバイスサービスの初期化が完了しました');
    } catch (e, stackTrace) {
      AppLogger.debugError('ウェアラブルデバイスサービス初期化エラー', e);
      AppLogger.debugError('スタックトレース', stackTrace);
      AppLogger.debugError('エラータイプ', e.runtimeType);
      // エラーが発生してもアプリは起動を続行
      // ウェアラブルデバイス機能は使用できない可能性がある
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
class WearableTeaGardenApp extends StatefulWidget {
  WearableTeaGardenApp({super.key}) {
    /// エラーバウンダリーを一度だけ設定
    /// ウィジェットツリーでエラーが発生した場合に表示されるカスタムエラー画面
    _WearableTeaGardenAppState._setupErrorBuilder();
  }

  @override
  State<WearableTeaGardenApp> createState() => _WearableTeaGardenAppState();
}

class _WearableTeaGardenAppState extends State<WearableTeaGardenApp> {
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

      /// テーマのエラー色を使用
      /// ErrorWidget.builderはBuildContextを持たないため、
      /// TeaGardenThemeの色を使用してテーマに合わせたエラー画面を表示
      /// システムのダークモード設定を確認して適切な背景色を使用
      const errorColor = TeaGardenTheme.errorColor;
      final isWearable = PlatformUtils.isWearable;

      /// システムのダークモード設定を確認
      /// ErrorWidget.builderはBuildContextを持たないため、
      /// WidgetsBindingを使用してシステムの設定を取得
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = brightness == Brightness.dark;
      final backgroundColor = isDarkMode
          ? TeaGardenTheme.backgroundDark
          : TeaGardenTheme.backgroundLight;
      final textColor =
          isDarkMode ? TeaGardenTheme.textLight : TeaGardenTheme.textPrimary;

      return Material(
        color: backgroundColor,
        child: Container(
          color: errorColor.withOpacity(0.1),
          padding: EdgeInsets.all(isWearable ? 12.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isWearable ? 40 : 48,
                color: errorColor,
              ),
              SizedBox(height: isWearable ? 12 : 16),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: isWearable ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWearable ? 6 : 8),
              if (kDebugMode)
                Text(
                  details.exception.toString(),
                  style: TextStyle(
                    fontSize: isWearable ? 10 : 12,
                    color: textColor.withOpacity(0.7),
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
  void dispose() {
    /// アプリ終了時にリソースをクリーンアップ
    /// イベントストリームの購読をキャンセル
    _wearableEventSubscription?.cancel();
    _wearableEventSubscription = null;

    /// ウェアラブルデバイスサービスのリソースをクリーンアップ
    _globalWearableService?.dispose();
    _globalWearableService = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWearable = PlatformUtils.isWearable;

    /// ウェアラブル用のテーマを作成
    /// TeaGardenThemeをベースに、小さなフォントサイズを適用
    final wearableLightTheme = TeaGardenTheme.lightTheme.copyWith(
      textTheme: isWearable
          ? TeaGardenTheme.lightTheme.textTheme.copyWith(
              bodyLarge: const TextStyle(fontSize: 12),
              bodyMedium: const TextStyle(fontSize: 11),
              bodySmall: const TextStyle(fontSize: 10),
            )
          : TeaGardenTheme.lightTheme.textTheme,
    );

    final wearableDarkTheme = TeaGardenTheme.darkTheme.copyWith(
      textTheme: isWearable
          ? TeaGardenTheme.darkTheme.textTheme.copyWith(
              bodyLarge: const TextStyle(fontSize: 12),
              bodyMedium: const TextStyle(fontSize: 11),
              bodySmall: const TextStyle(fontSize: 10),
            )
          : TeaGardenTheme.darkTheme.textTheme,
    );

    return MaterialApp(
      title: LocalizationService.instance.translate('app_title'),
      theme: wearableLightTheme,
      darkTheme: wearableDarkTheme,
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
      home: const WearableHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

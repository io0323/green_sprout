import 'package:flutter/material.dart';
import 'dart:async';
import 'core/services/localization_service.dart';
import 'core/services/wearable_device_service.dart';
import 'core/utils/platform_utils.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/app_initialization.dart';
import 'core/theme/tea_garden_theme.dart';
import 'features/wearable/presentation/pages/wearable_home_page.dart';

/// グローバルなウェアラブルデバイスサービスインスタンス
/// アプリ全体でアクセス可能にするため
WearableDeviceServiceImpl? _globalWearableService;

/// イベントストリームの購読を管理するためのサブスクリプション
StreamSubscription<WearableEvent>? _wearableEventSubscription;

/// エラーメッセージ定数
class _WearableErrorMessages {
  _WearableErrorMessages._();
  static const String connectionCheckError = 'ウェアラブルデバイス接続確認エラー';
  static const String eventStreamError = 'ウェアラブルデバイスイベントストリームエラー';
  static const String wearableError = 'ウェアラブルデバイスエラー';
  static const String initializationError = 'ウェアラブルデバイスサービス初期化エラー';
}

/// ログメッセージ定数
class _WearableLogMessages {
  _WearableLogMessages._();
  static const String deviceConnected = 'ウェアラブルデバイスが接続されています';
  static const String deviceDisconnected = 'ウェアラブルデバイスは接続されていません';
  static const String deviceConnectedEvent = 'ウェアラブルデバイスが接続されました';
  static const String deviceDisconnectedEvent = 'ウェアラブルデバイスが切断されました';
  static const String dataReceived = 'ウェアラブルデバイスからデータを受信しました';
  static const String receivedData = '受信データ';
  static const String initializationComplete = 'ウェアラブルデバイスサービスの初期化が完了しました';
}

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
  } catch (e, stackTrace) {
    AppLogger.logErrorWithStackTrace(
      _WearableErrorMessages.connectionCheckError,
      e,
      stackTrace,
    );
    return false;
  }
}

/// ウェアラブルデバイスの接続状態を確認（非ブロッキング）
/// エラーが発生してもログに記録するだけで処理を続行
Future<void> _checkWearableConnection() async {
  try {
    final isConnected = await _globalWearableService!.isConnected();
    if (isConnected) {
      AppLogger.debugInfo(_WearableLogMessages.deviceConnected);
    } else {
      AppLogger.debugInfo(_WearableLogMessages.deviceDisconnected);
    }
  } catch (error, stackTrace) {
    AppLogger.logErrorWithStackTrace(
      _WearableErrorMessages.connectionCheckError,
      error,
      stackTrace,
    );
  }
}

/// ウェアラブルデバイスイベントを処理する
/// [event] 処理するイベント
void _handleWearableEvent(WearableEvent event) {
  switch (event.type) {
    case WearableEventType.connected:
      AppLogger.debugInfo(_WearableLogMessages.deviceConnectedEvent);
      break;
    case WearableEventType.disconnected:
      AppLogger.debugInfo(_WearableLogMessages.deviceDisconnectedEvent);
      break;
    case WearableEventType.dataReceived:
      AppLogger.debugInfo(_WearableLogMessages.dataReceived);
      if (event.data != null) {
        AppLogger.debugInfo(
            _WearableLogMessages.receivedData, event.data.toString());
      }
      break;
    case WearableEventType.error:
      AppLogger.debugError(
        _WearableErrorMessages.wearableError,
        event.error ?? '不明なエラー',
      );
      break;
  }
}

/// ウェアラブルデバイスサービスの初期化
/// エラーが発生してもアプリは起動を続行（ウェアラブルデバイス機能は使用できない可能性がある）
Future<void> _initializeWearableDeviceService() async {
  try {
    _globalWearableService = WearableDeviceServiceImpl();

    // イベントストリームを監視して接続状態の変化を処理
    _wearableEventSubscription = _globalWearableService!.eventStream.listen(
      _handleWearableEvent,
      onError: (error, stackTrace) {
        AppLogger.logErrorWithStackTrace(
          _WearableErrorMessages.eventStreamError,
          error,
          stackTrace,
        );
      },
    );

    // 接続状態を確認（非ブロッキング）
    _checkWearableConnection();

    AppLogger.debugInfo(_WearableLogMessages.initializationComplete);
  } catch (e, stackTrace) {
    AppLogger.logErrorWithStackTrace(
      _WearableErrorMessages.initializationError,
      e,
      stackTrace,
    );
    // エラーが発生してもアプリは起動を続行
    // ウェアラブルデバイス機能は使用できない可能性がある
  }
}

/// ウェアラブルデバイス用のアプリエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドラーの設定
  AppInitialization.setupGlobalErrorHandler();

  // 非同期エラーハンドラーの設定とアプリ実行
  await AppInitialization.runWithErrorHandling(() async {
    // 国際化サービスの初期化
    await AppInitialization.initializeLocalization();

    // DIコンテナの初期化
    await AppInitialization.initializeDependencyInjection();

    // エラーワジェットの設定（コンストラクタをconstにするためmainに移動）
    AppInitialization.setupErrorWidget();

    // ウェアラブルデバイスサービスの初期化
    await _initializeWearableDeviceService();

    runApp(const WearableTeaGardenApp());
  });
}

/// ウェアラブルデバイス用のアプリ
class WearableTeaGardenApp extends StatefulWidget {
  const WearableTeaGardenApp({super.key});

  @override
  State<WearableTeaGardenApp> createState() => _WearableTeaGardenAppState();
}

class _WearableTeaGardenAppState extends State<WearableTeaGardenApp> {
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

  /// ウェアラブル用のテーマテキストスタイルを作成
  /// [baseTextTheme] ベースとなるテキストテーマ
  /// ウェアラブルデバイスの場合は小さなフォントサイズを適用
  TextTheme _createWearableTextTheme(TextTheme baseTextTheme) {
    final isWearable = PlatformUtils.isWearable;
    if (!isWearable) {
      return baseTextTheme;
    }
    return baseTextTheme.copyWith(
      bodyLarge: const TextStyle(
        fontSize: TeaGardenTheme.wearableFontSizeLarge,
      ),
      bodyMedium: const TextStyle(
        fontSize: TeaGardenTheme.wearableFontSizeMedium,
      ),
      bodySmall: const TextStyle(
        fontSize: TeaGardenTheme.wearableFontSizeSmall,
      ),
    );
  }

  /// ウェアラブル用のライトテーマを作成
  /// TeaGardenThemeをベースに、小さなフォントサイズを適用
  ThemeData _createWearableLightTheme() {
    return TeaGardenTheme.lightTheme.copyWith(
      textTheme: _createWearableTextTheme(TeaGardenTheme.lightTheme.textTheme),
    );
  }

  /// ウェアラブル用のダークテーマを作成
  /// TeaGardenThemeをベースに、小さなフォントサイズを適用
  ThemeData _createWearableDarkTheme() {
    return TeaGardenTheme.darkTheme.copyWith(
      textTheme: _createWearableTextTheme(TeaGardenTheme.darkTheme.textTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appDefaults = AppInitialization.getMaterialAppDefaults();
    return MaterialApp(
      title: LocalizationService.instance.translate('app_title'),
      theme: _createWearableLightTheme(),
      darkTheme: _createWearableDarkTheme(),
      themeMode: appDefaults.themeMode,
      localizationsDelegates: appDefaults.localizationsDelegates,
      supportedLocales: appDefaults.supportedLocales,
      debugShowCheckedModeBanner: appDefaults.debugShowCheckedModeBanner,
      home: const WearableHomePage(),
    );
  }
}

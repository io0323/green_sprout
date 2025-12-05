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

/// ウェアラブルデバイスの接続状態を確認（非ブロッキング）
/// エラーが発生してもログに記録するだけで処理を続行
Future<void> _checkWearableConnection() async {
  try {
    final isConnected = await _globalWearableService!.isConnected();
    if (isConnected) {
      AppLogger.debugInfo('ウェアラブルデバイスが接続されています');
    } else {
      AppLogger.debugInfo('ウェアラブルデバイスは接続されていません');
    }
  } catch (error) {
    AppLogger.debugError('ウェアラブルデバイス接続確認エラー', error);
  }
}

/// ウェアラブルデバイスイベントを処理する
/// [event] 処理するイベント
void _handleWearableEvent(WearableEvent event) {
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
}

/// ウェアラブルデバイスサービスの初期化
/// エラーが発生してもアプリは起動を続行（ウェアラブルデバイス機能は使用できない可能性がある）
Future<void> _initializeWearableDeviceService() async {
  try {
    _globalWearableService = WearableDeviceServiceImpl();

    // イベントストリームを監視して接続状態の変化を処理
    _wearableEventSubscription = _globalWearableService!.eventStream.listen(
      _handleWearableEvent,
      onError: (error) {
        AppLogger.debugError('ウェアラブルデバイスイベントストリームエラー', error);
      },
    );

    // 接続状態を確認（非ブロッキング）
    _checkWearableConnection();

    AppLogger.debugInfo('ウェアラブルデバイスサービスの初期化が完了しました');
  } catch (e, stackTrace) {
    AppLogger.debugError('ウェアラブルデバイスサービス初期化エラー', e);
    AppLogger.debugError('スタックトレース', stackTrace);
    AppLogger.debugError('エラータイプ', e.runtimeType);
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

  /// ウェアラブル用のテーマを作成
  /// TeaGardenThemeをベースに、小さなフォントサイズを適用
  ThemeData _createWearableLightTheme() {
    final isWearable = PlatformUtils.isWearable;
    return TeaGardenTheme.lightTheme.copyWith(
      textTheme: isWearable
          ? TeaGardenTheme.lightTheme.textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: TeaGardenTheme.wearableFontSizeLarge,
              ),
              bodyMedium: const TextStyle(
                fontSize: TeaGardenTheme.wearableFontSizeMedium,
              ),
              bodySmall: const TextStyle(
                fontSize: TeaGardenTheme.wearableFontSizeSmall,
              ),
            )
          : TeaGardenTheme.lightTheme.textTheme,
    );
  }

  /// ウェアラブル用のダークテーマを作成
  /// TeaGardenThemeをベースに、小さなフォントサイズを適用
  ThemeData _createWearableDarkTheme() {
    final isWearable = PlatformUtils.isWearable;
    return TeaGardenTheme.darkTheme.copyWith(
      textTheme: isWearable
          ? TeaGardenTheme.darkTheme.textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: TeaGardenTheme.wearableFontSizeLarge,
              ),
              bodyMedium: const TextStyle(
                fontSize: TeaGardenTheme.wearableFontSizeMedium,
              ),
              bodySmall: const TextStyle(
                fontSize: TeaGardenTheme.wearableFontSizeSmall,
              ),
            )
          : TeaGardenTheme.darkTheme.textTheme,
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

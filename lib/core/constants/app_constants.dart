import 'package:camera/camera.dart';

/// アプリケーション全体で使用する定数
class AppConstants {
  // データベース関連
  static const String databaseName = 'tea_analysis.db';
  static const int databaseVersion = 1;

  // テーブル名
  static const String teaAnalysisTable = 'tea_analysis_results';

  // TensorFlow Lite関連
  static const String modelPath = 'assets/models/tea_model.tflite';
  static const int inputImageSize = 224;
  static const int inputChannels = 3;

  // カメラ関連
  static const ResolutionPreset cameraResolution = ResolutionPreset.high;

  // 信頼度の閾値
  static const double highConfidenceThreshold = 0.8;
  static const double mediumConfidenceThreshold = 0.6;
  static const double lowConfidenceThreshold = 0.4;

  // 画像解析関連の定数
  static const double brightnessThresholdLow = 100.0;
  static const double brightnessThresholdMedium = 150.0;
  static const double brightnessThresholdHigh = 200.0;
  static const double greennessThresholdLow = 0.4;
  static const double greennessThresholdMedium = 0.45;
  static const double greennessThresholdHigh = 0.5;
  static const double greennessThresholdVeryHigh = 0.55;
  static const double greennessThresholdExtraHigh = 0.6;
  static const double fallbackConfidenceLow = 0.75;
  static const double fallbackConfidenceMedium = 0.80;
  static const double fallbackConfidenceHigh = 0.85;
  static const double fallbackConfidenceVeryHigh = 0.90;

  /*
   * Webモック解析（高度な特徴量解析）関連の定数
   * - マジックナンバーを排除し、判定基準を調整しやすくする
   */
  static const double rgbMaxChannel = 255.0;
  static const double rgbMaxSum = 765.0; // 255 * 3
  static const double colorConsistencyCenter = 0.5;

  static const int edgeDiffThreshold = 50;
  static const double smoothnessHighThreshold = 0.8;
  static const double complexityLowThreshold = 0.1;
  static const double complexityMediumThreshold = 0.2;

  static const double healthScoreWeightGreenness = 0.4;
  static const double healthScoreWeightSmoothness = 0.3;
  static const double healthScoreWeightBrightness = 0.3;

  static const double healthScoreThresholdHealthy = 0.7;
  static const double healthScoreThresholdSlightlyDamaged = 0.5;
  static const double healthScoreThresholdDamaged = 0.3;

  // データベース関連の定数
  static const int maxQueryResults = 1000;

  // 設定関連の定数
  static const int retentionPeriodMin = 1;
  static const int retentionPeriodMax = 365;
  static const int autoAnalysisIntervalMin = 5;
  static const int autoAnalysisIntervalMax = 1440;

  // 日付計算関連の定数（日数）
  static const int daysOne = 1;
  static const int daysThree = 3;
  static const int daysFive = 5;
  static const int daysSeven = 7;
  static const int daysThirty = 30;
  static const int daysThreeHundredSixtyFive = 365;
}

/// 成長状態の定数
class GrowthStageConstants {
  static const String bud = '芽';
  static const String youngLeaf = '若葉';
  static const String matureLeaf = '成葉';
  static const String oldLeaf = '老葉';

  static const List<String> allStages = [
    bud,
    youngLeaf,
    matureLeaf,
    oldLeaf,
  ];
}

/// 健康状態の定数
class HealthStatusConstants {
  static const String healthy = '健康';
  static const String slightlyDamaged = '軽微な損傷';
  static const String damaged = '損傷';
  static const String diseased = '病気';

  static const List<String> allStatuses = [
    healthy,
    slightlyDamaged,
    damaged,
    diseased,
  ];
}

/// エラーメッセージの定数
class ErrorMessages {
  static const String cameraInitializationFailed = 'カメラの初期化に失敗しました';
  static const String imageCaptureFailed = '画像の撮影に失敗しました';
  static const String modelLoadFailed = 'AIモデルの読み込みに失敗しました';
  static const String analysisFailed = '画像解析に失敗しました';
  static const String saveFailed = 'データの保存に失敗しました';
  static const String loadFailed = 'データの読み込みに失敗しました';
  static const String deleteFailed = 'データの削除に失敗しました';
  static const String updateFailed = 'データの更新に失敗しました';
  static const String networkError = 'ネットワークエラーが発生しました';
  static const String unknownError = '不明なエラーが発生しました';

  // ウェアラブルデバイス関連のエラーメッセージ
  static const String wearableConnectionCheckError = 'ウェアラブルデバイス接続確認エラー';
  static const String wearableEventStreamError = 'ウェアラブルデバイスイベントストリームエラー';
  static const String wearableError = 'ウェアラブルデバイスエラー';
  static const String wearableInitializationError = 'ウェアラブルデバイスサービス初期化エラー';

  // ログ用途（共通）
  static const String translationDataLoadError = '翻訳データ読み込みエラー';
  static const String diInitializationError = 'DI初期化エラー';
  static const String flutterFrameworkError = 'Flutterエラー';
  static const String widgetTreeError = 'ウィジェットエラー';
  static const String unhandledAsyncError = '未処理の非同期エラー';
  static const String errorMessageFetchErrorFallback =
      'エラーメッセージ取得エラー（デフォルトメッセージ使用）';

  // ログ用途（画面遷移）
  static const String navigationToAnalysisResultError = '解析結果画面への遷移エラー';
  static const String navigationToCameraError = 'カメラ画面への遷移エラー';
  static const String cameraScreenReturnedError = 'カメラ画面からのエラー';
}

/// ログメッセージの定数
class LogMessages {
  // ウェアラブルデバイス関連のログメッセージ
  static const String wearableDeviceConnected = 'ウェアラブルデバイスが接続されています';
  static const String wearableDeviceDisconnected = 'ウェアラブルデバイスは接続されていません';
  static const String wearableDeviceConnectedEvent = 'ウェアラブルデバイスが接続されました';
  static const String wearableDeviceDisconnectedEvent = 'ウェアラブルデバイスが切断されました';
  static const String wearableDataReceived = 'ウェアラブルデバイスからデータを受信しました';
  static const String wearableReceivedData = '受信データ';
  static const String wearableInitializationComplete =
      'ウェアラブルデバイスサービスの初期化が完了しました';

  // 初期化関連
  static const String localizationInitializationComplete = '国際化サービスの初期化が完了しました';
  static const String diInitializationComplete = 'DIコンテナの初期化が完了しました';

  // AppLogger用ラベル
  static const String loggerLabelStackTrace = 'スタックトレース';
  static const String loggerLabelErrorType = 'エラータイプ';
  static const String loggerLabelErrorMessage = 'エラーメッセージ';
  static const String loggerLabelErrorCode = 'エラーコード';
}

/*
 * メトリクス収集関連の定数
 * - メトリクス名/単位/タグキー/デフォルト値を集約してマジック文字列を排除する
 */
class MetricsConstants {
  /* メトリクス名 */
  static const String memoryUsage = 'memory.usage';
  static const String errorsTotal = 'errors.total';
  static const String userActions = 'user.actions';
  static const String userActionPrefix = 'user.action';
  static const String timerPrefix = 'timer';
  static const String networkRequestDuration = 'network.request.duration';
  static const String networkRequestSize = 'network.request.size';
  static const String networkRequestsTotal = 'network.requests.total';
  static const String databaseOperationDuration = 'database.operation.duration';
  static const String databaseOperationRecords = 'database.operation.records';

  /* 単位 */
  static const String unitCount = 'count';
  static const String unitGauge = 'gauge';
  static const String unitMilliseconds = 'milliseconds';
  static const String unitBytes = 'bytes';

  /* タグキー */
  static const String tagOperation = 'operation';
  static const String tagErrorType = 'error_type';
  static const String tagContext = 'context';
  static const String tagAction = 'action';
  static const String tagDetail = 'detail';
  static const String tagMethod = 'method';
  static const String tagStatusCode = 'status_code';
  static const String tagUrl = 'url';
  static const String tagTable = 'table';

  /* デフォルト値 */
  static const String defaultUnknown = 'unknown';
  static const String invalidUrl = 'invalid_url';
}

/*
 * メトリクス/デバッグ表示用の文言定数
 * - MetricsCollector のログ/レポート生成で使用する文字列を集約する
 */
class MetricsMessages {
  static const String debugMetricRecordedPrefix = 'Metric recorded:';
  static const String reportHeader = '=== Metrics Report ===';
  static const String reportTotalMetricsPrefix = 'Total metrics:';
  static const String reportActiveTimersPrefix = 'Active timers:';

  static const String reportCountLabel = 'Count';
  static const String reportSumLabel = 'Sum';
  static const String reportAverageLabel = 'Average';
  static const String reportMinLabel = 'Min';
  static const String reportMaxLabel = 'Max';

  static const String urlSanitizeError = 'URLサニタイズエラー';
}

/*
 * HTTP/ネットワーク関連の定数
 * - タイムアウトやリトライ、ヘッダー等のマジックナンバー/文字列を集約する
 */
class HttpConstants {
  /* リトライ/タイムアウト */
  static const int maxRetries = 3;
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int retryBackoffSecondsBase = 2;

  /* レスポンス制限 */
  static const int maxResponseBytes = 10 * 1024 * 1024; // 10MB

  /* デフォルトヘッダー */
  static const String headerContentType = 'Content-Type';
  static const String headerUserAgent = 'User-Agent';
  static const String contentTypeJson = 'application/json';
  static const String defaultUserAgent = 'TeaGardenAI/1.0.0';
}

/*
 * クラウド同期関連の定数
 * - APIのベースURL/エンドポイント/保存キーを集約してマジック文字列を排除する
 */
class CloudSyncConstants {
  /* API */
  static const String baseUrl = 'https://api.tea-garden-ai.com';
  static const String healthPath = '/health';
  static const String syncEndpointPath = '/api/v1/sync';

  /* SharedPreferences keys */
  static const String keyAutoSyncEnabled = 'auto_sync_enabled';
  static const String keyLastSyncTimestamp = 'last_sync_timestamp';
  static const String keyUserId = 'user_id';
}

/*
 * テスト用HTTPクライアント関連の定数
 * - injection_container.dart の _TestHttpClient で使用する値を集約する
 */
class TestHttpClientConstants {
  static const int successStatusCode = 200;
  static const String emptyJsonObject = '{}';
  static const String emptyBody = '';
}

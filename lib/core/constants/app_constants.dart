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

/*
 * ウェアラブル連携関連の定数
 * - MethodChannel名 / メソッド名 / ペイロードキーなどのマジックストリングを排除する
 */
class WearableChannelConstants {
  static const String channelName = 'tea_garden_wearable';

  /* Dart -> Native */
  static const String methodIsConnected = 'isWearableConnected';
  static const String methodConnect = 'connectWearable';
  static const String methodDisconnect = 'disconnectWearable';
  static const String methodSendToWearable = 'sendToWearable';
  static const String methodSendHeartbeat = 'sendHeartbeat';

  /* Native -> Dart */
  static const String callbackOnConnected = 'onWearableConnected';
  static const String callbackOnDisconnected = 'onWearableDisconnected';
  static const String callbackOnDataReceived = 'onWearableDataReceived';
  static const String callbackOnError = 'onWearableError';
}

/*
 * ウェアラブル送受信ペイロードの定数
 * - JSONキーや種別文字列を集約してタイポや不整合を防ぐ
 */
class WearablePayloadConstants {
  static const String wrapperKeyData = 'data';

  /* Common keys */
  static const String keyType = 'type';
  static const String keyTimestamp = 'timestamp';

  /* Analysis result keys */
  static const String typeAnalysisResult = 'analysis_result';
  static const String keyId = 'id';
  static const String keyGrowthStage = 'growthStage';
  static const String keyHealthStatus = 'healthStatus';
  static const String keyConfidence = 'confidence';
  static const String keyComment = 'comment';

  /* Notification keys */
  static const String typeNotification = 'notification';
  static const String keyTitle = 'title';
  static const String keyMessage = 'message';
}

/*
 * ウェアラブルUI関連の定数
 * - 画面上の件数制限など、仕様値を集約する
 */
class WearableUiConstants {
  static const int maxRecentResults = 10;
}

/*
 * 画面遷移（Navigator）の戻り値/引数で使用するキー
 * - Mapベースで値をやり取りする箇所のマジックストリングを排除する
 */
class NavigationResultKeys {
  /* CameraPage -> 呼び出し元 */
  static const String cameraImagePath = 'imagePath';
  static const String cameraErrorMessage = 'error';
}

/*
 * アプリ内ルーティング（Navigator.pushNamed等）で使用するルート名
 * - 直書きによるtypoを防ぎ、参照元を統一する
 */
class RouteNames {
  static const String camera = '/camera';
  static const String analysis = '/analysis';
  static const String logs = '/logs';
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
  static const String wearableConnectError = 'ウェアラブルデバイス接続エラー';
  static const String wearableDisconnectError = 'ウェアラブルデバイス切断エラー';
  static const String wearableDataSendError = 'ウェアラブルデバイスデータ送信エラー';
  static const String wearableNotificationSendError = 'ウェアラブルデバイス通知送信エラー';
  static const String wearableHeartbeatError = 'ウェアラブルデバイスハートビートエラー';

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
  static const String analysisResultsLoadError = '解析結果の読み込みエラー';

  /*
   * 茶葉解析（TFLite/フォールバック）関連
   * - Failureメッセージ等で使用する共通文言を集約する
   */
  static const String teaAnalysisImageLoadFailed = '画像の読み込みに失敗しました';
  static const String teaAnalysisModelLoadFailedPrefix = 'モデルの読み込みに失敗しました:';
  static const String teaAnalysisAnalysisFailedPrefix = '画像解析に失敗しました:';
  static const String teaAnalysisWebAnalysisFailedPrefix = 'Web解析に失敗しました:';
  static const String teaAnalysisFallbackAnalysisFailedPrefix =
      'フォールバック解析に失敗しました:';
  static const String teaAnalysisTfliteModelNotLoaded =
      'TensorFlow Liteモデルが読み込まれていません';
  static const String teaAnalysisTfliteAnalysisFailedPrefix =
      'TensorFlow Lite解析に失敗しました:';
  static const String teaAnalysisAdvancedAnalysisFailedPrefix = '高度な解析エラー:';
  static const String teaAnalysisAdvancedEngineInitFailedPrefix =
      '高度な解析エンジンの初期化に失敗しました:';

  /*
   * SecureHttpClient関連
   * - ネットワークリトライ等で使用する例外メッセージを集約する
   */
  static const String secureHttpRequestTimeout = 'Request timeout';
  static const String secureHttpNetworkError = 'Network error';
  static const String secureHttpError = 'HTTP error';
  static const String secureHttpUnexpectedErrorPrefix = 'Unexpected error:';
  static const String secureHttpMaxRetriesExceeded = 'Max retries exceeded';

  // CloudSyncService関連
  static const String cloudSyncNoInternet = 'インターネット接続がありません';
  static const String cloudSyncFailedPrefix = '同期に失敗しました:';
  static const String cloudSyncErrorPrefix = 'クラウド同期エラー:';

  // PerformanceUtils関連
  static const String performanceImageLoadError = '画像読み込みエラー';
  static const String databaseConnectionPoolClosed = 'Connection pool closed';

  // PlatformUtils関連（ログ用途）
  static const String platformWearOsCheckError = 'Wear OS判定エラー';
  static const String platformWatchOsCheckError = 'watchOS判定エラー';

  // SecurityUtils関連（ログ用途）
  static const String securityEncryptError = '暗号化エラー';
  static const String securityDecryptError = '復号化エラー';
  static const String securityInvalidEncryptedDataFormat =
      'Invalid encrypted data format';

  // SecurityUtils関連（環境変数）
  static const String securityEncryptionKeyEnvNotSetWarning =
      'ENCRYPTION_KEY environment variable not set. Using fallback key.';
  static const String securityEncryptionKeyEnvNotSetException =
      'Encryption key not set in environment variable ENCRYPTION_KEY. '
      'Please set this variable in your deployment environment.';

  // FailureMessageMapper関連（ログ用途）
  static const String localizationServiceFallbackError =
      '国際化サービスエラー（フォールバック使用）';
  static const String localizationServiceDefaultError = '国際化サービスエラー（デフォルト値使用）';

  // TFLite関連（ログ用途）
  static const String tfliteModelLoadError = 'TFLiteモデル読み込みエラー';
  static const String tfliteInputTensorError = '入力テンソル取得エラー';
  static const String tfliteOutputTensorError = '出力テンソル取得エラー';
  static const String tfliteInferenceError = 'モデル推論エラー';
  static const String tfliteInferenceWithInputError = 'モデル推論エラー（入力データ）';
  static const String tfliteModelOutputError = 'モデル出力取得エラー';
  static const String tfliteNativeInterpreterCreateError =
      'TFLiteインタープリター作成エラー（ネイティブ）';

  // AppInitialization関連（UIフォールバック）
  static const String errorOccurred = 'エラーが発生しました';
}

/*
 * SecurityUtils関連の定数
 * - 環境変数名や開発用フォールバックキーなど、直書きになりがちな値を集約する
 */
class SecurityConstants {
  static const String envEncryptionKey = 'ENCRYPTION_KEY';
  static const String fallbackEncryptionKey =
      'default_fallback_key_please_change';
}

/*
 * ログメッセージの定数（HTTP）
 * - SecureHttpClientのログコンテキスト等で使用する
 */
class HttpLogMessages {
  static const String secureHttpRequestError = 'HTTPリクエストエラー';
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

  // CloudSyncService関連（ログ用途）
  static const String cloudSyncConnectionCheckError = 'クラウド接続確認エラー';
  static const String cloudSyncSendError = 'クラウド同期エラー（送信）';
  static const String cloudSyncReceiveError = 'クラウド同期エラー（受信）';

  /*
   * 茶葉解析（Webモック/ローカル）関連（ログ用途）
   * - AppLoggerのログコンテキスト文字列を集約する
   */
  static const String teaAnalysisTfliteInitFallback =
      'TensorFlow Lite初期化エラー（フォールバック使用）';
  static const String teaAnalysisModelLoadError = 'モデル読み込みエラー';
  static const String teaAnalysisModelLoadFallbackError =
      'モデル読み込みエラー（フォールバック使用）';
  static const String teaAnalysisImageAnalysisErrorWeb = '画像解析エラー（Web）';
  static const String teaAnalysisImageAnalysisError = '画像解析エラー';
  static const String teaAnalysisWebAnalysisError = 'Web解析エラー';
  static const String teaAnalysisFallbackAnalysisErrorWeb = 'フォールバック解析エラー（Web）';
  static const String teaAnalysisFallbackAnalysisError = 'フォールバック解析エラー';
  static const String teaAnalysisTfliteAnalysisError = 'TensorFlow Lite解析エラー';
  static const String teaAnalysisAdvancedAnalysisError = '高度な解析エラー';
  static const String teaAnalysisAdvancedEngineInitError = '高度な解析エンジン初期化エラー';
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

  /* JSON keys */
  static const String jsonKeyName = 'name';
  static const String jsonKeyValue = 'value';
  static const String jsonKeyUnit = 'unit';
  static const String jsonKeyTimestamp = 'timestamp';
  static const String jsonKeyTags = 'tags';

  /* デフォルト値 */
  static const String defaultUnknown = 'unknown';
  static const String invalidUrl = 'invalid_url';

  /*
   * 保持上限
   * - 長時間動作で _metrics が無制限に増えないようにする
   */
  static const int maxMetricEntries = 1000;
}

/*
 * メトリクス/デバッグ表示用の文言定数
 * - MetricsCollector のログ/レポート生成で使用する文字列を集約する
 */
class MetricsMessages {
  static const String debugMetricRecordedPrefix = 'Metric recorded:';
  static const String debugErrorRecordedPrefix = 'Error recorded:';
  static const String debugErrorContextLabel = MetricsConstants.tagContext;
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

  /* HTTPステータス */
  static const int statusOk = 200;

  /* レスポンス制限 */
  static const int maxResponseBytes = 10 * 1024 * 1024; // 10MB

  /* デフォルトヘッダー */
  static const String headerContentType = 'Content-Type';
  static const String headerUserAgent = 'User-Agent';
  static const String headerAuthorization = 'Authorization';

  static const String contentTypeJson = 'application/json';
  static const String defaultUserAgent = 'TeaGardenAI/1.0.0';

  /* 認証 */
  static const String bearerPrefix = 'Bearer ';

  /* 共通ヘッダー */
  static const Map<String, String> jsonContentTypeHeaders = {
    headerContentType: contentTypeJson,
  };
}

/*
 * クラウド同期関連の定数
 * - APIのベースURL/エンドポイント/保存キーを集約してマジック文字列を排除する
 */
class CloudSyncConstants {
  /* API */
  static const String envKeyApiBaseUrl = 'TEA_GARDEN_AI_API_BASE_URL';

  /*
   * Cloud Sync API Base URL
   * - `--dart-define=TEA_GARDEN_AI_API_BASE_URL=...` で環境ごとに切替可能
   * - 未指定時はデフォルト値を使用（現状挙動は維持）
   */
  static const String baseUrl = String.fromEnvironment(
    envKeyApiBaseUrl,
    defaultValue: 'https://api.tea-garden-ai.com',
  );
  static const String healthPath = '/health';
  static const String syncEndpointPath = '/api/v1/sync';

  /* SharedPreferences keys */
  static const String keyAutoSyncEnabled = 'auto_sync_enabled';
  static const String keyLastSyncTimestamp = 'last_sync_timestamp';
  static const String keyUserId = 'user_id';
  static const String keyOfflineSyncQueue = 'offline_sync_queue';

  /* JSON keys */
  static const String jsonKeyUserId = 'userId';
  static const String jsonKeyResults = 'results';
  static const String jsonKeyTimestamp = 'timestamp';

  /*
   * TeaAnalysisResult JSON keys（Cloud Sync用）
   * - cloud_sync_service.dart 内の変換処理で使用するキーを集約する
   */
  static const String jsonKeyResultId = 'id';
  static const String jsonKeyResultImagePath = 'imagePath';
  static const String jsonKeyResultGrowthStage = 'growthStage';
  static const String jsonKeyResultHealthStatus = 'healthStatus';
  static const String jsonKeyResultConfidence = 'confidence';
  static const String jsonKeyResultComment = 'comment';

  /* Query params */
  static const String queryParamUserId = jsonKeyUserId;
  static const String queryParamSince = 'since';
}

/*
 * Cloud Sync の同期状態表示用文言
 * - UI表示で使う直書き文言を集約して変更容易性を上げる
 */
class CloudSyncStatusMessages {
  static const String empty = '';
  static const String syncing = '同期中...';
  static const String success = '同期完了';
  static const String offline = 'オフライン';
}

/*
 * テスト用HTTPクライアント関連の定数
 * - injection_container.dart の _TestHttpClient で使用する値を集約する
 */
class TestHttpClientConstants {
  static const int successStatusCode = HttpConstants.statusOk;
  static const String emptyJsonObject = '{}';
  static const String emptyBody = '';
}

/*
 * パフォーマンス/メモリ監視関連の定数
 * - performance_utils.dart 内のマジックナンバー/キーを集約する
 */
class PerformanceConstants {
  static const int bytesPerMegabyte = 1024 * 1024;

  static const int memoryLogMaxEntries = 100;
  static const int memoryWarningThresholdMb = 200;
  static const int memoryRecentLogsMaxEntries = 10;

  static const int imageCacheMaxEntries = 50;
  static const int maxDatabaseConnections = 5;
}

/*
 * パフォーマンス監視のログ文言（デバッグ）
 * - 文言を集約してマジック文字列を削減する
 */
class PerformanceLogMessages {
  static const String timerPrefix = '⏱️';
  static const String timeUnitMilliseconds = 'ms';

  static const String memoryPrefix = '🧠 Memory';
  static const String memoryUnitMb = 'MB';

  /* サイズ単位 */
  static const String sizeUnitBytes = 'bytes';

  static const String imageLoadedPrefix = 'Image loaded:';
  static const String imageCacheEntryPrefix = '📸 Cached image:';
  static const String imageCacheCleared = '🗑️ Image cache cleared';

  static const String highMemoryUsageDetected = 'High memory usage detected:';
  static const String recentMemoryLogsHeader = '📊 Recent memory logs:';
  static const String recentMemoryLogIndent = '   ';
}

/*
 * パフォーマンス統計のキー定義
 * - getPerformanceStats()/getCacheStats() の返却キーを集約する
 */
class PerformanceStatsKeys {
  static const String activeTimers = 'active_timers';
  static const String memoryLogsCount = 'memory_logs_count';
  static const String currentMemoryMb = 'current_memory_mb';

  static const String cachedImages = 'cached_images';
  static const String totalSizeBytes = 'total_size_bytes';
  static const String totalSizeMb = 'total_size_mb';
}

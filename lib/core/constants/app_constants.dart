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
  static const double fallbackConfidenceLow = 0.75;
  static const double fallbackConfidenceMedium = 0.80;
  static const double fallbackConfidenceHigh = 0.85;
  static const double fallbackConfidenceVeryHigh = 0.90;

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
}

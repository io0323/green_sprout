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

  // UI関連
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  static const double padding = 16.0;

  // 信頼度の閾値
  static const double highConfidenceThreshold = 0.8;
  static const double mediumConfidenceThreshold = 0.6;
  static const double lowConfidenceThreshold = 0.4;
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
}

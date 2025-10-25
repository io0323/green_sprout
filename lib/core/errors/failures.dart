/// クリーンアーキテクチャのコア層
/// エラーハンドリングとユースケースの基底クラス
library;

/// アプリケーション全体で使用するエラークラス
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);
}

/// サーバー関連のエラー
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// キャッシュ関連のエラー
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// ネットワーク関連のエラー
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// カメラ関連のエラー
class CameraFailure extends Failure {
  const CameraFailure(super.message, [super.code]);
}

/// TensorFlow Lite関連のエラー
class TFLiteFailure extends Failure {
  const TFLiteFailure(super.message, [super.code]);
}

/// 汎用的なエラー
class GenericFailure extends Failure {
  const GenericFailure(super.message, [super.code]);
}

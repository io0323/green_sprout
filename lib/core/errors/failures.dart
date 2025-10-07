/**
 * クリーンアーキテクチャのコア層
 * エラーハンドリングとユースケースの基底クラス
 */

/**
 * アプリケーション全体で使用するエラークラス
 */
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);
}

/**
 * サーバー関連のエラー
 */
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/**
 * キャッシュ関連のエラー
 */
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/**
 * ネットワーク関連のエラー
 */
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/**
 * カメラ関連のエラー
 */
class CameraFailure extends Failure {
  const CameraFailure(super.message, [super.code]);
}

/**
 * TensorFlow Lite関連のエラー
 */
class TFLiteFailure extends Failure {
  const TFLiteFailure(super.message, [super.code]);
}

/**
 * 汎用的なエラー
 */
class GenericFailure extends Failure {
  const GenericFailure(super.message, [super.code]);
}

/**
 * Either型の実装
 * 成功時はRight、失敗時はLeftを返す
 */
abstract class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

/**
 * ユースケースの基底クラス
 * 全てのユースケースはこのクラスを継承
 */
abstract class UseCase<Type, Params> {
  /**
   * ユースケースを実行
   * @param params パラメータ
   * @return Either<Failure, Type> 成功時はRight、失敗時はLeft
   */
  Future<Either<Failure, Type>> call(Params params);
}

/**
 * パラメータなしのユースケースの基底クラス
 */
abstract class UseCaseNoParams<Type> {
  /**
   * ユースケースを実行
   * @return Either<Failure, Type> 成功時はRight、失敗時はLeft
   */
  Future<Either<Failure, Type>> call();
}

/**
 * パラメータなしのユースケース用の空クラス
 */
class NoParams {
  const NoParams();
}

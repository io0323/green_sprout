import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// ユースケースの基底クラス
/// すべてのユースケースはこのクラスを継承する
abstract class UseCase<Type, Params> {
  /// ユースケースを実行する
  Future<Either<Failure, Type>> call(Params params);
}

/// パラメータが不要なユースケースの基底クラス
abstract class UseCaseNoParams<Type> {
  /// ユースケースを実行する
  Future<Either<Failure, Type>> call();
}

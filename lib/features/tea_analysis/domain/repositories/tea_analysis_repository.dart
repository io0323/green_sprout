import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/tea_analysis_result.dart';

/// 茶葉解析結果リポジトリの抽象クラス
/// データ層とドメイン層の境界を定義
abstract class TeaAnalysisRepository {
  /// 全ての茶葉解析結果を取得する
  Future<Either<Failure, List<TeaAnalysisResult>>> getAllTeaAnalysisResults();

  /// 特定の日の茶葉解析結果を取得する
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysisResultsForDate(
      DateTime date);

  /// 新しい茶葉解析結果を保存する
  Future<Either<Failure, TeaAnalysisResult>> saveTeaAnalysisResult(
      TeaAnalysisResult result);

  /// 茶葉解析結果を更新する
  Future<Either<Failure, TeaAnalysisResult>> updateTeaAnalysisResult(
      TeaAnalysisResult result);

  /// 特定のIDの茶葉解析結果を削除する
  Future<Either<Failure, Unit>> deleteTeaAnalysisResult(String id);
}

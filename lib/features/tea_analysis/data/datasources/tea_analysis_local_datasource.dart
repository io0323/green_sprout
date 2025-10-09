import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tea_analysis_result.dart';

/// 茶葉解析結果のローカルデータソースの抽象クラス
/// SQLiteなどの永続化層とのやり取りを定義
abstract class TeaAnalysisLocalDataSource {
  /// 新しい茶葉解析結果を保存する
  Future<Either<Failure, TeaAnalysisResult>> saveTeaAnalysisResult(TeaAnalysisResult result);

  /// 全ての茶葉解析結果を取得する
  Future<Either<Failure, List<TeaAnalysisResult>>> getAllTeaAnalysisResults();

  /// 特定の日の茶葉解析結果を取得する
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysisResultsForDate(DateTime date);

  /// 茶葉解析結果を更新する
  Future<Either<Failure, TeaAnalysisResult>> updateTeaAnalysisResult(TeaAnalysisResult result);

  /// 特定のIDの茶葉解析結果を削除する
  Future<Either<Failure, Unit>> deleteTeaAnalysisResult(String id);
}
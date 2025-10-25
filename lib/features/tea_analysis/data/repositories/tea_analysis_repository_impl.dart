import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../../domain/repositories/tea_analysis_repository.dart';
import '../datasources/tea_analysis_local_datasource.dart';

/// 茶葉解析結果リポジトリの実装
/// データ層とドメイン層の境界を実装
class TeaAnalysisRepositoryImpl implements TeaAnalysisRepository {
  final TeaAnalysisLocalDataSource localDataSource;

  TeaAnalysisRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>>
      getAllTeaAnalysisResults() async {
    try {
      final result = await localDataSource.getAllTeaAnalysisResults();
      return result;
    } catch (e) {
      return Left(CacheFailure('データの取得に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysisResultsForDate(
      DateTime date) async {
    try {
      final result = await localDataSource.getTeaAnalysisResultsForDate(date);
      return result;
    } catch (e) {
      return Left(CacheFailure('データの取得に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> saveTeaAnalysisResult(
      TeaAnalysisResult result) async {
    try {
      final savedResult = await localDataSource.saveTeaAnalysisResult(result);
      return savedResult;
    } catch (e) {
      return Left(CacheFailure('データの保存に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> updateTeaAnalysisResult(
      TeaAnalysisResult result) async {
    try {
      final updatedResult =
          await localDataSource.updateTeaAnalysisResult(result);
      return updatedResult;
    } catch (e) {
      return Left(CacheFailure('データの更新に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTeaAnalysisResult(String id) async {
    try {
      final result = await localDataSource.deleteTeaAnalysisResult(id);
      return result;
    } catch (e) {
      return Left(CacheFailure('データの削除に失敗しました: $e'));
    }
  }
}

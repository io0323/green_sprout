import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../../domain/repositories/tea_analysis_repository.dart';
import '../datasources/tea_analysis_local_datasource.dart';
import '../models/tea_analysis_result_model.dart';

/**
 * 茶葉解析結果リポジトリの実装
 * データ層とドメイン層の境界を実装
 */
class TeaAnalysisRepositoryImpl implements TeaAnalysisRepository {
  final TeaAnalysisLocalDataSource localDataSource;

  TeaAnalysisRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getAllTeaAnalyses() async {
    try {
      final models = await localDataSource.getAllTeaAnalyses();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('データの取得に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, TeaAnalysisResult?>> getTeaAnalysis(int id) async {
    try {
      final model = await localDataSource.getTeaAnalysis(id);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(CacheFailure('データの取得に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> saveTeaAnalysis(TeaAnalysisResult teaAnalysis) async {
    try {
      final model = TeaAnalysisResultModel.fromEntity(teaAnalysis);
      final id = await localDataSource.insertTeaAnalysis(model);
      return Right(id);
    } catch (e) {
      return Left(CacheFailure('データの保存に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTeaAnalysis(TeaAnalysisResult teaAnalysis) async {
    try {
      final model = TeaAnalysisResultModel.fromEntity(teaAnalysis);
      await localDataSource.updateTeaAnalysis(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('データの更新に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeaAnalysis(int id) async {
    try {
      await localDataSource.deleteTeaAnalysis(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('データの削除に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await localDataSource.getTeaAnalysesByDateRange(startDate, endDate);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('データの検索に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysesByGrowthStage(
    String growthStage,
  ) async {
    try {
      final models = await localDataSource.getTeaAnalysesByGrowthStage(growthStage);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('データの検索に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTodayTeaAnalyses() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final models = await localDataSource.getTeaAnalysesByDateRange(startOfDay, endOfDay);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('今日のデータの取得に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getRecentTeaAnalyses(int limit) async {
    try {
      final models = await localDataSource.getRecentTeaAnalyses(limit);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('最近のデータの取得に失敗しました: $e'));
    }
  }
}

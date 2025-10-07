import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/tea_analysis_result.dart';
import '../repositories/tea_analysis_repository.dart';

/**
 * 全ての茶葉解析結果を取得するユースケース
 */
class GetAllTeaAnalyses implements UseCaseNoParams<List<TeaAnalysisResult>> {
  final TeaAnalysisRepository repository;

  GetAllTeaAnalyses(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call() async {
    return await repository.getAllTeaAnalyses();
  }
}

/**
 * IDで茶葉解析結果を取得するユースケース
 */
class GetTeaAnalysis implements UseCase<TeaAnalysisResult?, int> {
  final TeaAnalysisRepository repository;

  GetTeaAnalysis(this.repository);

  @override
  Future<Either<Failure, TeaAnalysisResult?>> call(int params) async {
    return await repository.getTeaAnalysis(params);
  }
}

/**
 * 茶葉解析結果を保存するユースケース
 */
class SaveTeaAnalysis implements UseCase<int, TeaAnalysisResult> {
  final TeaAnalysisRepository repository;

  SaveTeaAnalysis(this.repository);

  @override
  Future<Either<Failure, int>> call(TeaAnalysisResult params) async {
    return await repository.saveTeaAnalysis(params);
  }
}

/**
 * 茶葉解析結果を更新するユースケース
 */
class UpdateTeaAnalysis implements UseCase<void, TeaAnalysisResult> {
  final TeaAnalysisRepository repository;

  UpdateTeaAnalysis(this.repository);

  @override
  Future<Either<Failure, void>> call(TeaAnalysisResult params) async {
    return await repository.updateTeaAnalysis(params);
  }
}

/**
 * 茶葉解析結果を削除するユースケース
 */
class DeleteTeaAnalysis implements UseCase<void, int> {
  final TeaAnalysisRepository repository;

  DeleteTeaAnalysis(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await repository.deleteTeaAnalysis(params);
  }
}

/**
 * 日付範囲で茶葉解析結果を検索するユースケース
 */
class GetTeaAnalysesByDateRange implements UseCase<List<TeaAnalysisResult>, DateRangeParams> {
  final TeaAnalysisRepository repository;

  GetTeaAnalysesByDateRange(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call(DateRangeParams params) async {
    return await repository.getTeaAnalysesByDateRange(params.startDate, params.endDate);
  }
}

/**
 * 成長状態で茶葉解析結果を検索するユースケース
 */
class GetTeaAnalysesByGrowthStage implements UseCase<List<TeaAnalysisResult>, String> {
  final TeaAnalysisRepository repository;

  GetTeaAnalysesByGrowthStage(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call(String params) async {
    return await repository.getTeaAnalysesByGrowthStage(params);
  }
}

/**
 * 今日の茶葉解析結果を取得するユースケース
 */
class GetTodayTeaAnalyses implements UseCaseNoParams<List<TeaAnalysisResult>> {
  final TeaAnalysisRepository repository;

  GetTodayTeaAnalyses(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call() async {
    return await repository.getTodayTeaAnalyses();
  }
}

/**
 * 最近の茶葉解析結果を取得するユースケース
 */
class GetRecentTeaAnalyses implements UseCase<List<TeaAnalysisResult>, int> {
  final TeaAnalysisRepository repository;

  GetRecentTeaAnalyses(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call(int params) async {
    return await repository.getRecentTeaAnalyses(params);
  }
}

/**
 * 日付範囲パラメータクラス
 */
class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  DateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}

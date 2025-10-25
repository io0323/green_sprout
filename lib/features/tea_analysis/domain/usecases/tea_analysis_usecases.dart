import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tea_analysis_result.dart';
import '../repositories/tea_analysis_repository.dart';

/// 全ての茶葉解析結果を取得するユースケース
class GetAllTeaAnalysisResults
    implements UseCaseNoParams<List<TeaAnalysisResult>> {
  final TeaAnalysisRepository repository;

  GetAllTeaAnalysisResults(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call() async {
    return await repository.getAllTeaAnalysisResults();
  }
}

/// 特定の日の茶葉解析結果を取得するユースケース
class GetTeaAnalysisResultsForDate
    implements UseCase<List<TeaAnalysisResult>, DateTime> {
  final TeaAnalysisRepository repository;

  GetTeaAnalysisResultsForDate(this.repository);

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> call(DateTime date) async {
    return await repository.getTeaAnalysisResultsForDate(date);
  }
}

/// 茶葉解析結果を保存するユースケース
class SaveTeaAnalysisResult
    implements UseCase<TeaAnalysisResult, TeaAnalysisResult> {
  final TeaAnalysisRepository repository;

  SaveTeaAnalysisResult(this.repository);

  @override
  Future<Either<Failure, TeaAnalysisResult>> call(
      TeaAnalysisResult result) async {
    return await repository.saveTeaAnalysisResult(result);
  }
}

/// 茶葉解析結果を更新するユースケース
class UpdateTeaAnalysisResult
    implements UseCase<TeaAnalysisResult, TeaAnalysisResult> {
  final TeaAnalysisRepository repository;

  UpdateTeaAnalysisResult(this.repository);

  @override
  Future<Either<Failure, TeaAnalysisResult>> call(
      TeaAnalysisResult result) async {
    return await repository.updateTeaAnalysisResult(result);
  }
}

/// 茶葉解析結果を削除するユースケース
class DeleteTeaAnalysisResult implements UseCase<Unit, String> {
  final TeaAnalysisRepository repository;

  DeleteTeaAnalysisResult(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteTeaAnalysisResult(id);
  }
}

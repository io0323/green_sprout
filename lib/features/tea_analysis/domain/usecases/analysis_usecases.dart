import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/analysis_result.dart';
import '../repositories/analysis_repository.dart';

/**
 * AIモデルを読み込むユースケース
 */
class LoadAnalysisModel implements UseCaseNoParams<void> {
  final AnalysisRepository repository;

  LoadAnalysisModel(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.loadModel();
  }
}

/**
 * 画像を解析するユースケース
 */
class AnalyzeImage implements UseCase<AnalysisResult, String> {
  final AnalysisRepository repository;

  AnalyzeImage(this.repository);

  @override
  Future<Either<Failure, AnalysisResult>> call(String params) async {
    return await repository.analyzeImage(params);
  }
}

/**
 * モデルが読み込まれているかチェックするユースケース
 */
class CheckModelLoaded implements UseCaseNoParams<bool> {
  final AnalysisRepository repository;

  CheckModelLoaded(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    return Right(repository.isModelLoaded);
  }
}

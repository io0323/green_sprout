import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analysis_result.dart';
import '../repositories/analysis_repository.dart';

/// AIモデルをロードするユースケース
class LoadAnalysisModel implements UseCaseNoParams<Unit> {
  final AnalysisRepository repository;

  LoadAnalysisModel(this.repository);

  @override
  Future<Either<Failure, Unit>> call() async {
    return await repository.loadModel();
  }
}

/// 画像を解析するユースケース
class AnalyzeImage implements UseCase<AnalysisResult, File> {
  final AnalysisRepository repository;

  AnalyzeImage(this.repository);

  @override
  Future<Either<Failure, AnalysisResult>> call(File imageFile) async {
    return await repository.analyzeImage(imageFile);
  }
}

/// モデルが読み込まれているかチェックするユースケース
class CheckModelLoaded implements UseCaseNoParams<bool> {
  final AnalysisRepository repository;

  CheckModelLoaded(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    return Right(repository.isModelLoaded);
  }
}
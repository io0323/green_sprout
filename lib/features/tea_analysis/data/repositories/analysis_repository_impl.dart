import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_local_datasource.dart';

/// AI解析リポジトリの実装
/// TensorFlow Liteモデルを使用した画像解析
class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisLocalDataSource localDataSource;

  AnalysisRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Unit>> loadModel() async {
    try {
      final result = await localDataSource.loadModel();
      return result;
    } catch (e) {
      return Left(TFLiteFailure('モデルの読み込みに失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, AnalysisResult>> analyzeImage(File imageFile) async {
    try {
      final result = await localDataSource.analyzeImage(imageFile);
      return result;
    } catch (e) {
      return Left(TFLiteFailure('画像解析に失敗しました: $e'));
    }
  }

  @override
  bool get isModelLoaded => localDataSource.isModelLoaded;
}

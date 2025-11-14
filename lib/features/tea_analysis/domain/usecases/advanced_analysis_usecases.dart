import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:image/image.dart' as img;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analysis_result.dart';
import '../../../../core/engines/advanced_analysis_engine.dart';

/// 高度な画像解析を実行するユースケース
class AdvancedAnalyzeImage implements UseCase<AnalysisResult, File> {
  final AdvancedAnalysisEngine advancedAnalysisEngine;

  AdvancedAnalyzeImage(this.advancedAnalysisEngine);

  @override
  Future<Either<Failure, AnalysisResult>> call(File imageFile) async {
    try {
      // 画像ファイルを読み込み
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return const Left(TFLiteFailure('画像の読み込みに失敗しました'));
      }

      // 高度な解析エンジンで解析
      final result = await advancedAnalysisEngine.analyzeImage(image);

      return Right(result);
    } catch (e) {
      return Left(TFLiteFailure('高度な解析エラー: ${e.toString()}'));
    }
  }
}

/// 高度な解析エンジンを初期化するユースケース
class InitializeAdvancedAnalysisEngine implements UseCaseNoParams<Unit> {
  final AdvancedAnalysisEngine advancedAnalysisEngine;

  InitializeAdvancedAnalysisEngine(this.advancedAnalysisEngine);

  @override
  Future<Either<Failure, Unit>> call() async {
    try {
      await advancedAnalysisEngine.initialize();
      return const Right(unit);
    } catch (e) {
      return Left(TFLiteFailure('高度な解析エンジンの初期化に失敗しました: ${e.toString()}'));
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_result.dart';

/// AI解析のローカルデータソースの抽象クラス
abstract class AnalysisLocalDataSource {
  /// TFLiteモデルで画像解析を実行
  Future<Either<Failure, AnalysisResult>> analyzeImage(String imagePath);
  
  /// モデルが読み込まれているかチェック
  Future<bool> isModelLoaded();
  
  /// モデルを読み込む
  Future<Either<Failure, void>> loadModel();
}
import '../../core/errors/failures.dart';
import '../entities/analysis_result.dart';

/**
 * AI解析サービスのリポジトリインターフェース
 * TensorFlow Liteモデルを使用した画像解析
 */
abstract class AnalysisRepository {
  /**
   * TensorFlow Liteモデルを読み込み
   */
  Future<Either<Failure, void>> loadModel();

  /**
   * 画像を解析して結果を返す
   */
  Future<Either<Failure, AnalysisResult>> analyzeImage(String imagePath);

  /**
   * モデルが読み込まれているかチェック
   */
  bool get isModelLoaded;

  /**
   * リソースを解放
   */
  void dispose();
}

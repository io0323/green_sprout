import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/core/errors/failures.dart';
import 'package:tea_garden_ai/features/tea_analysis/domain/entities/analysis_result.dart';
import 'package:tea_garden_ai/features/tea_analysis/data/datasources/analysis_local_datasource.dart';

/**
 * Web用のモック分析データソース
 * TensorFlow Liteの代わりにモック分析結果を返す
 */
class WebMockAnalysisDataSource implements AnalysisLocalDataSource {
  bool _isModelLoaded = false;

  @override
  Future<Either<Failure, Unit>> loadModel() async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }
    
    // モデル読み込みをシミュレート
    await Future.delayed(const Duration(seconds: 2));
    _isModelLoaded = true;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, AnalysisResult>> analyzeImage(File imageFile) async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }
    
    // 分析処理をシミュレート
    await Future.delayed(const Duration(seconds: 3));
    
    // ランダムな分析結果を生成
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    final result = AnalysisResult(
      growthStage: _getRandomGrowthStage(random),
      healthStatus: random % 10 < 2 ? '注意' : '健康',
      confidence: 0.85 + (random % 15) / 100, // 0.85-0.99の範囲
    );
    
    return Right(result);
  }

  @override
  bool get isModelLoaded => _isModelLoaded;

  String _getRandomGrowthStage(int random) {
    final stages = ['発芽期', '成長期', '成熟期', '収穫期'];
    return stages[random % stages.length];
  }
}

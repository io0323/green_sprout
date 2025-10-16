import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/features/tea_analysis/data/datasources/analysis_local_datasource.dart';

/**
 * Web用のモック分析データソース
 * TensorFlow Liteの代わりにモック分析結果を返す
 */
class WebMockAnalysisDataSource implements AnalysisLocalDataSource {
  @override
  Future<bool> loadModel() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    // モデル読み込みをシミュレート
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    // 分析処理をシミュレート
    await Future.delayed(const Duration(seconds: 3));
    
    // ランダムな分析結果を生成
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    return {
      'health_score': 70 + (random % 30), // 70-99の範囲
      'growth_stage': _getRandomGrowthStage(random),
      'disease_detected': random % 10 < 2, // 20%の確率で病気を検出
      'disease_type': random % 10 < 2 ? _getRandomDiseaseType(random) : null,
      'confidence': 0.85 + (random % 15) / 100, // 0.85-0.99の範囲
      'analysis_time': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<bool> isModelLoaded() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    return true;
  }

  String _getRandomGrowthStage(int random) {
    final stages = ['発芽期', '成長期', '成熟期', '収穫期'];
    return stages[random % stages.length];
  }

  String _getRandomDiseaseType(int random) {
    final diseases = [
      '葉枯れ病',
      'うどんこ病',
      '炭疽病',
      '茶の斑点病',
    ];
    return diseases[random % diseases.length];
  }
}

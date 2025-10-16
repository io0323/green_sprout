import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/features/tea_analysis/domain/entities/tea_analysis_result.dart';
import 'package:tea_garden_ai/features/tea_analysis/data/datasources/tea_analysis_local_datasource.dart';

/**
 * Web用のモックデータソース
 * 実際のデータベースの代わりにメモリ内のデータを使用
 */
class WebMockTeaAnalysisDataSource implements TeaAnalysisLocalDataSource {
  final List<TeaAnalysisResult> _mockData = [
    TeaAnalysisResult(
      id: '1',
      imagePath: '/assets/images/sample_tea_1.jpg',
      analysisDate: DateTime.now().subtract(const Duration(days: 1)),
      healthScore: 85,
      growthStage: '成熟期',
      diseaseDetected: false,
      diseaseType: null,
      notes: '健康な茶葉です。良好な成長状態を維持しています。',
    ),
    TeaAnalysisResult(
      id: '2',
      imagePath: '/assets/images/sample_tea_2.jpg',
      analysisDate: DateTime.now().subtract(const Duration(days: 3)),
      healthScore: 72,
      growthStage: '成長期',
      diseaseDetected: true,
      diseaseType: '軽度の葉枯れ病',
      notes: '軽度の葉枯れ病が検出されました。適切な対処が必要です。',
    ),
    TeaAnalysisResult(
      id: '3',
      imagePath: '/assets/images/sample_tea_3.jpg',
      analysisDate: DateTime.now().subtract(const Duration(days: 5)),
      healthScore: 90,
      growthStage: '成熟期',
      diseaseDetected: false,
      diseaseType: null,
      notes: '非常に健康な茶葉です。理想的な成長状態です。',
    ),
  ];

  @override
  Future<List<TeaAnalysisResult>> getAllResults() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    // 非同期処理をシミュレート
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockData);
  }

  @override
  Future<List<TeaAnalysisResult>> getResultsForDate(DateTime date) async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.where((result) {
      return result.analysisDate.year == date.year &&
             result.analysisDate.month == date.month &&
             result.analysisDate.day == date.day;
    }).toList();
  }

  @override
  Future<String> saveResult(TeaAnalysisResult result) async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    final newId = (_mockData.length + 1).toString();
    final newResult = result.copyWith(id: newId);
    _mockData.insert(0, newResult);
    return newId;
  }

  @override
  Future<void> updateResult(TeaAnalysisResult result) async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockData.indexWhere((r) => r.id == result.id);
    if (index != -1) {
      _mockData[index] = result;
    }
  }

  @override
  Future<void> deleteResult(String id) async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    _mockData.removeWhere((result) => result.id == id);
  }
}

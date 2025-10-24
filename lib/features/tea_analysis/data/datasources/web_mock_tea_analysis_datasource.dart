import 'package:dartz/dartz.dart';
import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/core/errors/failures.dart';
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
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      healthStatus: '健康',
      growthStage: '成熟期',
      confidence: 0.85,
      comment: '健康な茶葉です。良好な成長状態を維持しています。',
    ),
    TeaAnalysisResult(
      id: '2',
      imagePath: '/assets/images/sample_tea_2.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      healthStatus: '注意',
      growthStage: '成長期',
      confidence: 0.72,
      comment: '軽度の葉枯れ病が検出されました。適切な対処が必要です。',
    ),
    TeaAnalysisResult(
      id: '3',
      imagePath: '/assets/images/sample_tea_3.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      healthStatus: '健康',
      growthStage: '成熟期',
      confidence: 0.90,
      comment: '非常に健康な茶葉です。理想的な成長状態です。',
    ),
  ];

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>>
      getAllTeaAnalysisResults() async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    // 非同期処理をシミュレート
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(List.from(_mockData));
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysisResultsForDate(
      DateTime date) async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final results = _mockData.where((result) {
      return result.timestamp.year == date.year &&
          result.timestamp.month == date.month &&
          result.timestamp.day == date.day;
    }).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> saveTeaAnalysisResult(
      TeaAnalysisResult result) async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final newId = (_mockData.length + 1).toString();
    final newResult = result.copyWith(id: newId);
    _mockData.insert(0, newResult);
    return Right(newResult);
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> updateTeaAnalysisResult(
      TeaAnalysisResult result) async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockData.indexWhere((r) => r.id == result.id);
    if (index != -1) {
      _mockData[index] = result;
      return Right(result);
    }
    return const Left(ServerFailure('指定されたIDの結果が見つかりません'));
  }

  @override
  Future<Either<Failure, Unit>> deleteTeaAnalysisResult(String id) async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final initialLength = _mockData.length;
    _mockData.removeWhere((result) => result.id == id);
    final finalLength = _mockData.length;

    if (initialLength > finalLength) {
      return const Right(unit);
    }
    return const Left(ServerFailure('指定されたIDの結果が見つかりません'));
  }
}

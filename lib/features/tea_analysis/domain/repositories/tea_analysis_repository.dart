import '../../core/errors/failures.dart';
import '../entities/tea_analysis_result.dart';

/**
 * 茶葉解析結果のリポジトリインターフェース
 * ドメイン層とデータ層の境界を定義
 */
abstract class TeaAnalysisRepository {
  /**
   * 全ての茶葉解析結果を取得
   */
  Future<Either<Failure, List<TeaAnalysisResult>>> getAllTeaAnalyses();

  /**
   * IDで茶葉解析結果を取得
   */
  Future<Either<Failure, TeaAnalysisResult?>> getTeaAnalysis(int id);

  /**
   * 茶葉解析結果を保存
   */
  Future<Either<Failure, int>> saveTeaAnalysis(TeaAnalysisResult teaAnalysis);

  /**
   * 茶葉解析結果を更新
   */
  Future<Either<Failure, void>> updateTeaAnalysis(TeaAnalysisResult teaAnalysis);

  /**
   * 茶葉解析結果を削除
   */
  Future<Either<Failure, void>> deleteTeaAnalysis(int id);

  /**
   * 日付範囲で茶葉解析結果を検索
   */
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /**
   * 成長状態で茶葉解析結果を検索
   */
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysesByGrowthStage(
    String growthStage,
  );

  /**
   * 今日の茶葉解析結果を取得
   */
  Future<Either<Failure, List<TeaAnalysisResult>>> getTodayTeaAnalyses();

  /**
   * 最近の茶葉解析結果を取得
   */
  Future<Either<Failure, List<TeaAnalysisResult>>> getRecentTeaAnalyses(int limit);
}

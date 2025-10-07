import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tea_analysis_result.dart';

/// 茶葉解析のローカルデータソースの抽象クラス
abstract class TeaAnalysisLocalDataSource {
  /// 解析結果を保存
  Future<Either<Failure, void>> saveAnalysisResult(TeaAnalysisResult result);
  
  /// 解析結果を取得
  Future<Either<Failure, List<TeaAnalysisResult>>> getAnalysisResults();
  
  /// 解析結果を削除
  Future<Either<Failure, void>> deleteAnalysisResult(int id);
  
  /// 解析結果を更新
  Future<Either<Failure, void>> updateAnalysisResult(TeaAnalysisResult result);
  
  /// 今日の解析結果を取得
  Future<Either<Failure, List<TeaAnalysisResult>>> getTodayAnalysisResults();
}
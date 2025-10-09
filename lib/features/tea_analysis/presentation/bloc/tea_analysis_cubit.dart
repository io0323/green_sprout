import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../../domain/usecases/tea_analysis_usecases.dart';

/**
 * 茶葉解析結果の状態
 */
abstract class TeaAnalysisState {}

/**
 * 初期状態
 */
class TeaAnalysisInitial extends TeaAnalysisState {}

/**
 * 読み込み中
 */
class TeaAnalysisLoading extends TeaAnalysisState {}

/**
 * 読み込み完了
 */
class TeaAnalysisLoaded extends TeaAnalysisState {
  final List<TeaAnalysisResult> results;

  TeaAnalysisLoaded(this.results);
}

/**
 * エラー状態
 */
class TeaAnalysisError extends TeaAnalysisState {
  final String message;

  TeaAnalysisError(this.message);
}

/**
 * 茶葉解析結果のCubit
 * 状態管理とビジネスロジックの実行
 */
class TeaAnalysisCubit extends Cubit<TeaAnalysisState> {
  final GetAllTeaAnalysisResults getAllTeaAnalysisResults;
  final GetTeaAnalysisResultsForDate getTeaAnalysisResultsForDate;
  final SaveTeaAnalysisResult saveTeaAnalysisResult;
  final UpdateTeaAnalysisResult updateTeaAnalysisResult;
  final DeleteTeaAnalysisResult deleteTeaAnalysisResult;

  TeaAnalysisCubit({
    required this.getAllTeaAnalysisResults,
    required this.getTeaAnalysisResultsForDate,
    required this.saveTeaAnalysisResult,
    required this.updateTeaAnalysisResult,
    required this.deleteTeaAnalysisResult,
  }) : super(TeaAnalysisInitial());

  /**
   * 全ての茶葉解析結果を取得
   */
  Future<void> loadAllResults() async {
    emit(TeaAnalysisLoading());

    final result = await getAllTeaAnalysisResults();

    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
    );
  }

  /**
   * 特定の日の茶葉解析結果を取得
   */
  Future<void> loadResultsForDate(DateTime date) async {
    emit(TeaAnalysisLoading());

    final result = await getTeaAnalysisResultsForDate(date);

    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
    );
  }

  /**
   * 茶葉解析結果を保存
   */
  Future<void> saveResult(TeaAnalysisResult result) async {
    final saveResult = await saveTeaAnalysisResult(result);

    saveResult.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (savedResult) {
        // 保存成功後、全データを再読み込み
        loadAllResults();
      },
    );
  }

  /**
   * 茶葉解析結果を更新
   */
  Future<void> updateResult(TeaAnalysisResult result) async {
    final updateResult = await updateTeaAnalysisResult(result);

    updateResult.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (updatedResult) {
        // 更新成功後、全データを再読み込み
        loadAllResults();
      },
    );
  }

  /**
   * 茶葉解析結果を削除
   */
  Future<void> deleteResult(String id) async {
    final deleteResult = await deleteTeaAnalysisResult(id);

    deleteResult.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (unit) {
        // 削除成功後、全データを再読み込み
        loadAllResults();
      },
    );
  }

  /**
   * エラーをメッセージに変換
   */
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'サーバーエラーが発生しました: ${failure.message}';
      case CacheFailure:
        return 'データエラーが発生しました: ${failure.message}';
      case NetworkFailure:
        return 'ネットワークエラーが発生しました: ${failure.message}';
      case CameraFailure:
        return 'カメラエラーが発生しました: ${failure.message}';
      case TFLiteFailure:
        return 'AI解析エラーが発生しました: ${failure.message}';
      default:
        return '不明なエラーが発生しました: ${failure.message}';
    }
  }
}
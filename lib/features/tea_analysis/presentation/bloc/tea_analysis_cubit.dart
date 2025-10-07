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
  final GetAllTeaAnalyses getAllTeaAnalyses;
  final GetTeaAnalysis getTeaAnalysis;
  final SaveTeaAnalysis saveTeaAnalysis;
  final UpdateTeaAnalysis updateTeaAnalysis;
  final DeleteTeaAnalysis deleteTeaAnalysis;
  final GetTeaAnalysesByDateRange getTeaAnalysesByDateRange;
  final GetTeaAnalysesByGrowthStage getTeaAnalysesByGrowthStage;
  final GetTodayTeaAnalyses getTodayTeaAnalyses;
  final GetRecentTeaAnalyses getRecentTeaAnalyses;

  TeaAnalysisCubit({
    required this.getAllTeaAnalyses,
    required this.getTeaAnalysis,
    required this.saveTeaAnalysis,
    required this.updateTeaAnalysis,
    required this.deleteTeaAnalysis,
    required this.getTeaAnalysesByDateRange,
    required this.getTeaAnalysesByGrowthStage,
    required this.getTodayTeaAnalyses,
    required this.getRecentTeaAnalyses,
  }) : super(TeaAnalysisInitial());

  /**
   * 全ての茶葉解析結果を取得
   */
  Future<void> getAllTeaAnalyses() async {
    emit(TeaAnalysisLoading());
    
    final result = await getAllTeaAnalyses();
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
    );
  }

  /**
   * IDで茶葉解析結果を取得
   */
  Future<void> getTeaAnalysis(int id) async {
    emit(TeaAnalysisLoading());
    
    final result = await getTeaAnalysis(id);
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (result) {
        if (result != null) {
          emit(TeaAnalysisLoaded([result]));
        } else {
          emit(TeaAnalysisError('解析結果が見つかりません'));
        }
      },
    );
  }

  /**
   * 茶葉解析結果を保存
   */
  Future<void> saveTeaAnalysis(TeaAnalysisResult teaAnalysis) async {
    final result = await saveTeaAnalysis(teaAnalysis);
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (id) {
        // 保存成功後、全データを再読み込み
        getAllTeaAnalyses();
      },
    );
  }

  /**
   * 茶葉解析結果を更新
   */
  Future<void> updateTeaAnalysis(TeaAnalysisResult teaAnalysis) async {
    final result = await updateTeaAnalysis(teaAnalysis);
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (_) {
        // 更新成功後、全データを再読み込み
        getAllTeaAnalyses();
      },
    );
  }

  /**
   * 茶葉解析結果を削除
   */
  Future<void> deleteTeaAnalysis(int id) async {
    final result = await deleteTeaAnalysis(id);
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (_) {
        // 削除成功後、全データを再読み込み
        getAllTeaAnalyses();
      },
    );
  }

  /**
   * 日付範囲で茶葉解析結果を検索
   */
  Future<void> getTeaAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    emit(TeaAnalysisLoading());
    
    final result = await getTeaAnalysesByDateRange(
      DateRangeParams(startDate: startDate, endDate: endDate),
    );
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
    );
  }

  /**
   * 成長状態で茶葉解析結果を検索
   */
  Future<void> getTeaAnalysesByGrowthStage(String growthStage) async {
    emit(TeaAnalysisLoading());
    
    final result = await getTeaAnalysesByGrowthStage(growthStage);
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
    );
  }

  /**
   * 今日の茶葉解析結果を取得
   */
  Future<void> getTodayTeaAnalyses() async {
    emit(TeaAnalysisLoading());
    
    final result = await getTodayTeaAnalyses();
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
    );
  }

  /**
   * 最近の茶葉解析結果を取得
   */
  Future<void> getRecentTeaAnalyses(int limit) async {
    emit(TeaAnalysisLoading());
    
    final result = await getRecentTeaAnalyses(limit);
    
    result.fold(
      (failure) => emit(TeaAnalysisError(_mapFailureToMessage(failure))),
      (results) => emit(TeaAnalysisLoaded(results)),
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

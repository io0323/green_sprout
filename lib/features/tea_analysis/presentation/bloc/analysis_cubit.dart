import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/analysis_usecases.dart';

/**
 * AI解析の状態
 */
abstract class AnalysisState {}

/**
 * 初期状態
 */
class AnalysisInitial extends AnalysisState {}

/**
 * モデル読み込み中
 */
class AnalysisModelLoading extends AnalysisState {}

/**
 * モデル読み込み完了
 */
class AnalysisModelLoaded extends AnalysisState {}

/**
 * 解析中
 */
class AnalysisAnalyzing extends AnalysisState {}

/**
 * 解析完了
 */
class AnalysisLoaded extends AnalysisState {
  final AnalysisResult result;

  AnalysisLoaded(this.result);
}

/**
 * エラー状態
 */
class AnalysisError extends AnalysisState {
  final String message;

  AnalysisError(this.message);
}

/**
 * AI解析のCubit
 * TensorFlow Liteモデルの管理と画像解析の実行
 */
class AnalysisCubit extends Cubit<AnalysisState> {
  final LoadAnalysisModel loadAnalysisModel;
  final AnalyzeImage analyzeImage;
  final CheckModelLoaded checkModelLoaded;

  AnalysisCubit({
    required this.loadAnalysisModel,
    required this.analyzeImage,
    required this.checkModelLoaded,
  }) : super(AnalysisInitial());

  /**
   * AIモデルを読み込み
   */
  Future<void> loadModel() async {
    emit(AnalysisModelLoading());

    final result = await loadAnalysisModel();

    result.fold(
      (failure) => emit(AnalysisError(_mapFailureToMessage(failure))),
      (unit) => emit(AnalysisModelLoaded()),
    );
  }

  /**
   * 画像を解析（文字列パス版）
   */
  Future<void> analyzeImageFromPath(String imagePath) async {
    final imageFile = File(imagePath);
    await analyzeImageFile(imageFile);
  }

  /**
   * 画像を解析（File版）
   */
  Future<void> analyzeImageFile(File imageFile) async {
    emit(AnalysisAnalyzing());

    final result = await analyzeImage(imageFile);

    result.fold(
      (failure) => emit(AnalysisError(_mapFailureToMessage(failure))),
      (analysisResult) => emit(AnalysisLoaded(analysisResult)),
    );
  }

  /**
   * モデルが読み込まれているかチェック
   */
  Future<void> checkIfModelLoaded() async {
    final result = await checkModelLoaded();

    result.fold(
      (failure) => emit(AnalysisError(_mapFailureToMessage(failure))),
      (isLoaded) {
        if (isLoaded) {
          emit(AnalysisModelLoaded());
        } else {
          emit(AnalysisInitial());
        }
      },
    );
  }

  /**
   * 状態をリセット
   */
  void reset() {
    emit(AnalysisInitial());
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

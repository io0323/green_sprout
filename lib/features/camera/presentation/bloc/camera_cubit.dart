import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/camera_state.dart';
import '../../domain/usecases/camera_usecases.dart';

/**
 * カメラの状態
 */
abstract class CameraBlocState {}

/**
 * 初期状態
 */
class CameraInitial extends CameraBlocState {}

/**
 * カメラ初期化中
 */
class CameraInitializing extends CameraBlocState {}

/**
 * カメラ初期化完了
 */
class CameraInitialized extends CameraBlocState {
  final CameraState cameraState;

  CameraInitialized(this.cameraState);
}

/**
 * 撮影中
 */
class CameraCapturing extends CameraBlocState {}

/**
 * 撮影完了
 */
class CameraCaptured extends CameraBlocState {
  final String imagePath;

  CameraCaptured(this.imagePath);
}

/**
 * エラー状態
 */
class CameraError extends CameraBlocState {
  final String message;

  CameraError(this.message);
}

/**
 * カメラのCubit
 * カメラの状態管理と操作
 */
class CameraCubit extends Cubit<CameraBlocState> {
  final InitializeCamera initializeCamera;
  final CaptureImage captureImage;
  final DisposeCamera disposeCamera;
  final CheckCameraInitialized checkCameraInitialized;

  CameraCubit({
    required this.initializeCamera,
    required this.captureImage,
    required this.disposeCamera,
    required this.checkCameraInitialized,
  }) : super(CameraInitial());

  /**
   * カメラを初期化
   */
  Future<void> initialize() async {
    emit(CameraInitializing());

    final result = await initializeCamera();

    result.fold(
      (failure) => emit(CameraError(_mapFailureToMessage(failure))),
      (unit) {
        // 初期化成功後、現在の状態を取得
        checkCameraInitialized().then((result) {
          result.fold(
            (failure) => emit(CameraError(_mapFailureToMessage(failure))),
            (isInitialized) {
              if (isInitialized) {
                emit(CameraInitialized(const CameraState(isInitialized: true)));
              } else {
                emit(CameraInitial());
              }
            },
          );
        });
      },
    );
  }

  /**
   * 画像を撮影
   */
  Future<void> capture() async {
    emit(CameraCapturing());

    final result = await captureImage();

    result.fold(
      (failure) => emit(CameraError(_mapFailureToMessage(failure))),
      (imageFile) => emit(CameraCaptured(imageFile.path)),
    );
  }

  /**
   * カメラを破棄
   */
  Future<void> dispose() async {
    final result = await disposeCamera();

    result.fold(
      (failure) => emit(CameraError(_mapFailureToMessage(failure))),
      (unit) => emit(CameraInitial()),
    );
  }

  /**
   * 状態をリセット
   */
  void reset() {
    emit(CameraInitial());
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
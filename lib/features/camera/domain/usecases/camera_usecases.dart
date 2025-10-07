import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

/**
 * カメラを初期化するユースケース
 */
class InitializeCamera implements UseCaseNoParams<void> {
  final CameraRepository repository;

  InitializeCamera(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.initializeCamera();
  }
}

/**
 * 画像を撮影するユースケース
 */
class CaptureImage implements UseCaseNoParams<String> {
  final CameraRepository repository;

  CaptureImage(this.repository);

  @override
  Future<Either<Failure, String>> call() async {
    return await repository.captureImage();
  }
}

/**
 * カメラを破棄するユースケース
 */
class DisposeCamera implements UseCaseNoParams<void> {
  final CameraRepository repository;

  DisposeCamera(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.disposeCamera();
  }
}

/**
 * カメラが初期化されているかチェックするユースケース
 */
class CheckCameraInitialized implements UseCaseNoParams<bool> {
  final CameraRepository repository;

  CheckCameraInitialized(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    return Right(repository.isInitialized);
  }
}

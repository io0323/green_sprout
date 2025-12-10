import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/camera_state.dart';
import 'camera_local_datasource.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// テスト用のFakeカメラデータソース
/// テスト環境でカメラ機能をシミュレート
class FakeCameraDataSource implements CameraLocalDataSource {
  CameraState _currentState = const CameraState();
  bool _initialized = false;

  @override
  Future<Either<Failure, Unit>> initializeCamera() async {
    // テスト環境では即座に初期化完了
    await Future<void>.delayed(Duration.zero);
    _currentState = _currentState.copyWith(
      isInitialized: true,
      errorMessage: null,
    );
    _initialized = true;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, File>> captureImage() async {
    if (!_initialized) {
      return const Left(CameraFailure('カメラが初期化されていません'));
    }

    // テスト用のモック画像ファイルパスを返す
    await Future<void>.delayed(AnimationConstants.veryShortDuration);
    final mockImagePath =
        '/tmp/test_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final mockFile = File(mockImagePath);

    _currentState = _currentState.copyWith(
      isCapturing: false,
      capturedImagePath: mockImagePath,
    );

    return Right(mockFile);
  }

  @override
  Future<Either<Failure, Unit>> disposeCamera() async {
    await Future<void>.delayed(Duration.zero);
    _currentState = const CameraState();
    _initialized = false;
    return const Right(unit);
  }

  @override
  CameraState get currentState => _currentState;

  @override
  bool get isInitialized => _initialized;

  @override
  CameraController? get cameraController => null;
}

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/camera_state.dart';
import 'camera_local_datasource.dart';

/// カメラのローカルデータソース実装
/// カメラとの直接的なやり取りを実装
class CameraLocalDataSourceImpl implements CameraLocalDataSource {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraState _currentState = const CameraState();

  @override
  Future<Either<Failure, Unit>> initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras!.isEmpty) {
        return Left(const CameraFailure('カメラが見つかりません'));
      }

      // バックカメラを優先的に選択
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        camera,
        AppConstants.cameraResolution,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      _currentState = _currentState.copyWith(
        isInitialized: true,
        errorMessage: null,
      );
    } catch (e) {
      _currentState = _currentState.copyWith(
        errorMessage: e.toString(),
        isInitialized: false,
      );
      return Left(CameraFailure('カメラの初期化に失敗しました: $e'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, File>> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Left(const CameraFailure('カメラが初期化されていません'));
    }

    try {
      _currentState = _currentState.copyWith(isCapturing: true);

      final XFile image = await _cameraController!.takePicture();
      final imageFile = File(image.path);

      _currentState = _currentState.copyWith(
        isCapturing: false,
        capturedImagePath: image.path,
      );

      return Right(imageFile);
    } catch (e) {
      _currentState = _currentState.copyWith(
        isCapturing: false,
        errorMessage: e.toString(),
      );
      return Left(CameraFailure('画像の撮影に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _currentState = const CameraState();
    return const Right(unit);
  }

  @override
  CameraState get currentState => _currentState;

  @override
  bool get isInitialized => _currentState.isInitialized;
}
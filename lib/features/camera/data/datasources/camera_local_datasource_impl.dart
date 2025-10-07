import 'dart:io';
import 'package:camera/camera.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/camera_state.dart';
import 'camera_local_datasource.dart';

/**
 * カメラのローカルデータソース実装
 * カメラとの直接的なやり取りを実装
 */
class CameraLocalDataSourceImpl implements CameraLocalDataSource {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraState _currentState = const CameraState();

  @override
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras!.isEmpty) {
        throw Exception('カメラが見つかりません');
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
      rethrow;
    }
  }

  @override
  Future<String> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('カメラが初期化されていません');
    }

    try {
      _currentState = _currentState.copyWith(isCapturing: true);
      
      final XFile image = await _cameraController!.takePicture();
      final imagePath = image.path;
      
      _currentState = _currentState.copyWith(
        isCapturing: false,
        capturedImagePath: imagePath,
      );
      
      return imagePath;
    } catch (e) {
      _currentState = _currentState.copyWith(
        isCapturing: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _currentState = const CameraState();
  }

  @override
  CameraState get currentState => _currentState;

  @override
  bool get isInitialized => _currentState.isInitialized;
}

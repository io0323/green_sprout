import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/core/errors/failures.dart';
import 'package:tea_garden_ai/features/camera/domain/entities/camera_state.dart';
import 'package:tea_garden_ai/features/camera/data/datasources/camera_local_datasource.dart';

/// Web用のモックカメラデータソース
/// 実際のカメラの代わりにファイル選択を使用
class WebMockCameraDataSource implements CameraLocalDataSource {
  CameraState _currentState = const CameraState();
  CameraController? _mockController;

  @override
  Future<Either<Failure, Unit>> initializeCamera() async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    // カメラ初期化をシミュレート
    await Future.delayed(const Duration(milliseconds: 500));
    _currentState = _currentState.copyWith(isInitialized: true);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, File>> captureImage() async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    // Webでは実際のカメラキャプチャはできないため、
    // ファイル選択ダイアログをシミュレート
    await Future.delayed(const Duration(milliseconds: 300));

    // モック画像ファイルを作成
    final mockImagePath =
        '/tmp/mock_tea_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final mockFile = File(mockImagePath);

    // 実際のファイルは作成しないが、パスを返す
    _currentState = _currentState.copyWith(capturedImagePath: mockImagePath);
    return Right(mockFile);
  }

  @override
  Future<Either<Failure, Unit>> disposeCamera() async {
    if (!PlatformUtils.isWeb) {
      return const Left(ServerFailure('Web用のモックデータソースはWebプラットフォームでのみ使用可能です'));
    }

    // カメラ破棄をシミュレート
    await Future.delayed(const Duration(milliseconds: 200));
    _currentState = const CameraState();
    _mockController = null;
    return const Right(unit);
  }

  @override
  CameraState get currentState => _currentState;

  @override
  bool get isInitialized => _currentState.isInitialized;

  @override
  CameraController? get cameraController => _mockController;
}

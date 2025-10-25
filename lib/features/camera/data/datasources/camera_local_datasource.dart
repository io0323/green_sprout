import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/camera_state.dart';

/// カメラのローカルデータソースの抽象クラス
/// カメラとの直接的なやり取りを定義
abstract class CameraLocalDataSource {
  /// カメラを初期化する
  Future<Either<Failure, Unit>> initializeCamera();

  /// 画像を撮影する
  Future<Either<Failure, File>> captureImage();

  /// カメラを破棄する
  Future<Either<Failure, Unit>> disposeCamera();

  /// 現在のカメラの状態を取得する
  CameraState get currentState;

  /// カメラが初期化されているか
  bool get isInitialized;

  /// カメラコントローラーを取得
  CameraController? get cameraController;
}

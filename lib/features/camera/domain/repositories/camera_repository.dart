import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/camera_state.dart';

/// カメラリポジトリの抽象クラス
/// カメラの操作と状態管理の契約を定義
abstract class CameraRepository {
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
}
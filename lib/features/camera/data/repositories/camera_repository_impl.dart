import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/camera_state.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_local_datasource.dart';

/**
 * カメラリポジトリの実装
 * カメラの操作と状態管理
 */
class CameraRepositoryImpl implements CameraRepository {
  final CameraLocalDataSource localDataSource;

  CameraRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Unit>> initializeCamera() async {
    try {
      final result = await localDataSource.initializeCamera();
      return result;
    } catch (e) {
      return Left(CameraFailure('カメラの初期化に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> captureImage() async {
    try {
      final result = await localDataSource.captureImage();
      return result;
    } catch (e) {
      return Left(CameraFailure('画像の撮影に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> disposeCamera() async {
    try {
      final result = await localDataSource.disposeCamera();
      return result;
    } catch (e) {
      return Left(CameraFailure('カメラの破棄に失敗しました: $e'));
    }
  }

  @override
  CameraState get currentState => localDataSource.currentState;

  @override
  bool get isInitialized => localDataSource.isInitialized;
}
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
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
  Future<Either<Failure, void>> initializeCamera() async {
    try {
      await localDataSource.initializeCamera();
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure('カメラの初期化に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> captureImage() async {
    try {
      final imagePath = await localDataSource.captureImage();
      return Right(imagePath);
    } catch (e) {
      return Left(CameraFailure('画像の撮影に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disposeCamera() async {
    try {
      await localDataSource.disposeCamera();
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure('カメラの破棄に失敗しました: $e'));
    }
  }

  @override
  CameraState get currentState => localDataSource.currentState;

  @override
  bool get isInitialized => localDataSource.isInitialized;
}

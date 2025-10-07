import '../../core/errors/failures.dart';
import '../entities/camera_state.dart';

/**
 * カメラサービスのリポジトリインターフェース
 * カメラの操作と状態管理
 */
abstract class CameraRepository {
  /**
   * カメラを初期化
   */
  Future<Either<Failure, void>> initializeCamera();

  /**
   * 画像を撮影
   */
  Future<Either<Failure, String>> captureImage();

  /**
   * カメラを破棄
   */
  Future<Either<Failure, void>> disposeCamera();

  /**
   * 現在のカメラ状態を取得
   */
  CameraState get currentState;

  /**
   * カメラが初期化されているかチェック
   */
  bool get isInitialized;
}

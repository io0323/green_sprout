import '../../domain/entities/camera_state.dart';

/**
 * カメラのローカルデータソースインターフェース
 * カメラとの直接的なやり取りを定義
 */
abstract class CameraLocalDataSource {
  /**
   * カメラを初期化
   */
  Future<void> initializeCamera();

  /**
   * 画像を撮影
   */
  Future<String> captureImage();

  /**
   * カメラを破棄
   */
  Future<void> disposeCamera();

  /**
   * 現在のカメラ状態を取得
   */
  CameraState get currentState;

  /**
   * カメラが初期化されているかチェック
   */
  bool get isInitialized;
}

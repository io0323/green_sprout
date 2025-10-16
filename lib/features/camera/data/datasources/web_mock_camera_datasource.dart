import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/features/camera/data/datasources/camera_local_datasource.dart';

/**
 * Web用のモックカメラデータソース
 * 実際のカメラの代わりにファイル選択を使用
 */
class WebMockCameraDataSource implements CameraLocalDataSource {
  @override
  Future<bool> initializeCamera() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    // カメラ初期化をシミュレート
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<String?> captureImage() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    // Webでは実際のカメラキャプチャはできないため、
    // ファイル選択ダイアログをシミュレート
    await Future.delayed(const Duration(milliseconds: 300));
    
    // モック画像パスを返す
    return '/assets/images/sample_tea_${DateTime.now().millisecondsSinceEpoch % 3 + 1}.jpg';
  }

  @override
  Future<void> disposeCamera() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    // カメラ破棄をシミュレート
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<bool> isCameraInitialized() async {
    if (!PlatformUtils.isWeb) {
      throw UnsupportedError('Web用のモックデータソースはWebプラットフォームでのみ使用可能です');
    }
    
    return true;
  }
}

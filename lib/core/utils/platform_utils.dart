import 'package:flutter/foundation.dart';

/**
 * プラットフォーム検出ユーティリティ
 * Web、モバイル、デスクトップの判定を行う
 */
class PlatformUtils {
  /// Webプラットフォームかどうかを判定
  static bool get isWeb => kIsWeb;
  
  /// モバイルプラットフォームかどうかを判定
  static bool get isMobile => !kIsWeb;
  
  /// デバッグモードかどうかを判定
  static bool get isDebug => kDebugMode;
  
  /// リリースモードかどうかを判定
  static bool get isRelease => kReleaseMode;
}

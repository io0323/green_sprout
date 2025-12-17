import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'app_logger.dart';
import '../constants/app_constants.dart';

/// プラットフォーム検出ユーティリティ
/// Web、モバイル、デスクトップ、ウェアラブルの判定を行う
class PlatformUtils {
  /// Webプラットフォームかどうかを判定
  static bool get isWeb => kIsWeb;

  /// モバイルプラットフォームかどうかを判定
  static bool get isMobile => !kIsWeb;

  /// デバッグモードかどうかを判定
  static bool get isDebug => kDebugMode;

  /// リリースモードかどうかを判定
  static bool get isRelease => kReleaseMode;

  /// Wear OS（Android Wear）かどうかを判定
  static bool get isWearOS {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid &&
          (Platform.environment['WEAR_OS'] == 'true' ||
              Platform.environment.containsKey('WEAR_OS'));
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.platformWearOsCheckError,
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// watchOS（Apple Watch）かどうかを判定
  static bool get isWatchOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS &&
          (Platform.environment['WATCH_OS'] == 'true' ||
              Platform.environment.containsKey('WATCH_OS'));
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.platformWatchOsCheckError,
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// ウェアラブルデバイスかどうかを判定
  static bool get isWearable => isWearOS || isWatchOS;

  /// 通常のモバイルデバイスかどうかを判定（ウェアラブルを除く）
  static bool get isStandardMobile => isMobile && !isWearable;
}

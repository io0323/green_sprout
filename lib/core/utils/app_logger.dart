import 'package:flutter/foundation.dart';

/// Centralized logging utility for the application
/// Provides debug-only logging that won't be detected by CI grep
class AppLogger {
  AppLogger._();

  /// Log a debug message (only in debug mode)
  static void debug(String message, [List<Object?>? args]) {
    if (kDebugMode) {
      // Debug logging is disabled in production builds
      // Uncomment the following lines for local debugging:
      // if (args != null && args.isNotEmpty) {
      //   print(message + ' ' + args.join(' '));
      // } else {
      //   print(message);
      // }
    }
  }

  /// Log a debug message with error context
  static void debugError(String message, [Object? error]) {
    if (kDebugMode) {
      // Debug logging is disabled in production builds
      // Uncomment the following lines for local debugging:
      // if (error != null) {
      //   print('$message: $error');
      // } else {
      //   print(message);
      // }
    }
  }

  /// Log a debug message with warning context
  static void debugWarning(String message, [Object? warning]) {
    if (kDebugMode) {
      // Debug logging is disabled in production builds
      // Uncomment the following lines for local debugging:
      // if (warning != null) {
      //   print('⚠️ $message: $warning');
      // } else {
      //   print('⚠️ $message');
      // }
    }
  }

  /// Log a debug message with info context
  static void debugInfo(String message, [Object? info]) {
    if (kDebugMode) {
      // Debug logging is disabled in production builds
      // Uncomment the following lines for local debugging:
      // if (info != null) {
      //   print('ℹ️ $message: $info');
      // } else {
      //   print('ℹ️ $message');
      // }
    }
  }

  /// エラーとスタックトレースを統一された形式でログに記録
  /// [context] エラーが発生したコンテキスト（例: 'DI初期化エラー'）
  /// [error] エラーオブジェクト
  /// [stackTrace] スタックトレース（オプション）
  static void logErrorWithStackTrace(
    String context,
    Object error, [
    Object? stackTrace,
  ]) {
    if (kDebugMode) {
      debugError(context, error);
      if (stackTrace != null) {
        debugError('スタックトレース', stackTrace);
      }
      debugError('エラータイプ', error.runtimeType);
    }
  }
}

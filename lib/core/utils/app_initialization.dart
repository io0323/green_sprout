import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';
import 'package:tea_garden_ai/core/di/injection_container.dart' as di;
import 'package:tea_garden_ai/core/utils/app_logger.dart';

/// アプリケーション初期化処理を共通化するユーティリティ
/// 国際化サービスとDIコンテナの初期化を統一管理
class AppInitialization {
  AppInitialization._();

  /// 国際化サービスの初期化
  /// エラーが発生してもアプリは起動を続行（デフォルトの日本語翻訳が使用される）
  static Future<void> initializeLocalization() async {
    try {
      await LocalizationService.instance.loadTranslations();
      AppLogger.debugInfo('国際化サービスの初期化が完了しました');
    } catch (e, stackTrace) {
      AppLogger.debugError('翻訳データ読み込みエラー', e);
      AppLogger.debugError('スタックトレース', stackTrace);
      AppLogger.debugError('エラータイプ', e.runtimeType);
      // エラーが発生してもアプリは起動を続行
      // デフォルトの日本語翻訳が使用される
    }
  }

  /// DIコンテナの初期化
  /// エラーが発生してもアプリは起動を続行（DIに依存する機能は使用できない可能性がある）
  static Future<void> initializeDependencyInjection() async {
    try {
      await di.init();
      AppLogger.debugInfo('DIコンテナの初期化が完了しました');
    } catch (e, stackTrace) {
      AppLogger.debugError('DI初期化エラー', e);
      AppLogger.debugError('スタックトレース', stackTrace);
      AppLogger.debugError('エラータイプ', e.runtimeType);
      // エラーが発生してもアプリは起動を続行
      // ただし、DIに依存する機能は使用できない可能性がある
    }
  }

  /// グローバルエラーハンドラーの設定
  /// Flutterフレームワークレベルのエラーをキャッチ
  static void setupGlobalErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.debugError(
        'Flutterエラー',
        '${details.exception}\n${details.stack}',
      );
    };
  }

  /// 非同期エラーハンドラーの設定
  /// runZonedGuardedを使用して未処理の非同期エラーをキャッチ
  static Future<void> runWithErrorHandling(
    Future<void> Function() appRunner,
  ) async {
    await runZonedGuarded(
      () async => await appRunner(),
      (error, stack) {
        /// 未処理の非同期エラーをキャッチ
        /// アプリがクラッシュしないようにエラーをログに記録
        AppLogger.debugError('未処理の非同期エラー', error);
        AppLogger.debugError('スタックトレース', stack);
      },
    );
  }
}

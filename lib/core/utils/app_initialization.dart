import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';
import 'package:tea_garden_ai/core/di/injection_container.dart' as di;
import 'package:tea_garden_ai/core/utils/app_logger.dart';
import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/core/theme/tea_garden_theme.dart';

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

  /// エラーワジェットの設定
  /// ウィジェットツリーでエラーが発生した場合に表示されるカスタムエラー画面を設定
  static void setupErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      AppLogger.debugError('ウィジェットエラー', details.exception);
      AppLogger.debugError('スタックトレース', details.stack);

      /// 国際化サービスを使用してエラーメッセージを取得
      /// 初期化前の場合はデフォルトメッセージを使用
      String errorMessage;
      try {
        errorMessage = LocalizationService.instance.translate('error_occurred');
      } catch (e) {
        errorMessage = 'エラーが発生しました';
      }

      /// テーマのエラー色を使用
      /// ErrorWidget.builderはBuildContextを持たないため、
      /// TeaGardenThemeの色を使用してテーマに合わせたエラー画面を表示
      /// システムのダークモード設定を確認して適切な背景色を使用
      const errorColor = TeaGardenTheme.errorColor;
      final isWearable = PlatformUtils.isWearable;

      /// システムのダークモード設定を確認
      /// ErrorWidget.builderはBuildContextを持たないため、
      /// WidgetsBindingを使用してシステムの設定を取得
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = brightness == Brightness.dark;
      final backgroundColor = isDarkMode
          ? TeaGardenTheme.backgroundDark
          : TeaGardenTheme.backgroundLight;
      final textColor =
          isDarkMode ? TeaGardenTheme.textLight : TeaGardenTheme.textPrimary;

      return Material(
        color: backgroundColor,
        child: Container(
          color: errorColor.withOpacity(0.1),
          padding: EdgeInsets.all(isWearable ? 12.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isWearable ? 40 : 48,
                color: errorColor,
              ),
              SizedBox(height: isWearable ? 12 : 16),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: isWearable ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWearable ? 6 : 8),
              if (kDebugMode)
                Text(
                  details.exception.toString(),
                  style: TextStyle(
                    fontSize: isWearable ? 10 : 12,
                    color: textColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    };
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';
import 'package:tea_garden_ai/core/di/injection_container.dart' as di;
import 'package:tea_garden_ai/core/utils/app_logger.dart';
import 'package:tea_garden_ai/core/utils/platform_utils.dart';
import 'package:tea_garden_ai/core/utils/app_localizations.dart';
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
      AppLogger.debugInfo(LogMessages.localizationInitializationComplete);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.translationDataLoadError,
        e,
        stackTrace,
      );
      // エラーが発生してもアプリは起動を続行
      // デフォルトの日本語翻訳が使用される
    }
  }

  /// DIコンテナの初期化
  /// エラーが発生してもアプリは起動を続行（DIに依存する機能は使用できない可能性がある）
  static Future<void> initializeDependencyInjection() async {
    try {
      await di.init();
      AppLogger.debugInfo(LogMessages.diInitializationComplete);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.diInitializationError,
        e,
        stackTrace,
      );
      // エラーが発生してもアプリは起動を続行
      // ただし、DIに依存する機能は使用できない可能性がある
    }
  }

  /// グローバルエラーハンドラーの設定
  /// Flutterフレームワークレベルのエラーをキャッチ
  static void setupGlobalErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.flutterFrameworkError,
        details.exception,
        details.stack,
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
        AppLogger.logErrorWithStackTrace(
          ErrorMessages.unhandledAsyncError,
          error,
          stack,
        );
      },
    );
  }

  /// エラーワジェットの設定
  /// ウィジェットツリーでエラーが発生した場合に表示されるカスタムエラー画面を設定
  static void setupErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.widgetTreeError,
        details.exception,
        details.stack,
      );

      /// 国際化サービスを使用してエラーメッセージを取得
      /// 初期化前の場合はデフォルトメッセージを使用
      String errorMessage;
      try {
        errorMessage = LocalizationService.instance.translate('error_occurred');
      } catch (e, stackTrace) {
        AppLogger.logErrorWithStackTrace(
          ErrorMessages.errorMessageFetchErrorFallback,
          e,
          stackTrace,
        );
        errorMessage = ErrorMessages.errorOccurred;
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
          padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isWearable
                    ? TeaGardenTheme.errorIconSizeWearable
                    : TeaGardenTheme.errorIconSizeDefault,
                color: errorColor,
              ),
              const SizedBox(
                height: TeaGardenTheme.spacingM,
              ),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: isWearable
                      ? TeaGardenTheme.wearableFontSizeMedium
                      : TeaGardenTheme.bodyLarge.fontSize,
                  fontWeight: FontWeight.bold,
                  color: errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: isWearable
                    ? TeaGardenTheme.spacingXS
                    : TeaGardenTheme.spacingS,
              ),
              if (kDebugMode)
                Text(
                  details.exception.toString(),
                  style: TextStyle(
                    fontSize: isWearable
                        ? TeaGardenTheme.wearableFontSizeSmall
                        : TeaGardenTheme.bodySmall.fontSize,
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

  /// MaterialAppの共通設定を取得
  /// すべてのアプリで一貫したテーマ、ローカライゼーション、デバッグ設定を提供
  static MaterialAppData getMaterialAppDefaults() {
    return MaterialAppData(
      theme: TeaGardenTheme.lightTheme,
      darkTheme: TeaGardenTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// MaterialAppの共通設定データクラス
class MaterialAppData {
  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;
  final List<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final List<Locale> supportedLocales;
  final bool debugShowCheckedModeBanner;

  const MaterialAppData({
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
    required this.localizationsDelegates,
    required this.supportedLocales,
    required this.debugShowCheckedModeBanner,
  });
}

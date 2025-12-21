import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../src/web_storage.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// 国際化サービスクラス
/// アプリケーションの多言語対応を管理
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance =>
      _instance ??= LocalizationService._();

  LocalizationService._();

  Map<String, Map<String, String>> _translations = {};
  String _currentLanguage = 'ja';
  static const String _languageStorageKey = 'tea_garden_language';

  /*
   * フォールバック翻訳（最小セット）
   * - translations.json が読めない場合でも UI がキー文字列のまま露出しないようにする
   * - en は主要タイトル + router/advanced_analysis 系のみを最低限用意する
   */
  static const Map<String, Map<String, String>> _fallbackTranslations = {
    'en': {
      'app_title': 'Tea Garden AI',
      'home_title': 'Tea Garden Management',
      'camera_title': 'Take Photo',
      'analysis_title': 'Analysis Result',
      'logs_title': 'Analysis Logs',

      // Advanced analysis (AnalysisResultPage)
      'advanced_analysis': 'Advanced analysis',
      'advanced_analysis_description':
          'Run a high-accuracy analysis by combining multiple methods',
      'run_advanced_analysis': 'Run advanced analysis',
      'rerun_advanced_analysis': 'Re-run advanced analysis',

      // AppRouter fallback pages
      'router_unknown_route_title': 'Page not found',
      'router_invalid_navigation_title': 'Navigation failed',
      'router_web_unsupported_title': 'Not supported',
      'router_unknown_route_message': 'Unknown route: {route}',
      'router_invalid_arguments_message':
          'Invalid arguments for {route} (expected: {expected})',
      'router_web_unsupported_message':
          'This route is not supported on Web: {route}',
    },
    'ja': {
      'app_title': '茶園管理AI',
      'home_title': '茶園管理',
      'camera_title': '茶葉撮影',
      'analysis_title': '解析結果',
      'logs_title': '解析日誌',
      'take_photo': '茶葉を撮影・解析',
      'analyze': '解析開始',
      'save': '保存',
      'cancel': 'キャンセル',
      'search': '検索',
      'filter': 'フィルター',
      'growth_stage': '成長状態',
      'health_status': '健康状態',
      'confidence': '信頼度',
      'comment': 'コメント',
      'loading': '読み込み中...',
      'error': 'エラー',
      'retry': '再試行',
      'no_data': 'データがありません',
      'bud': '芽',
      'young_leaf': '若葉',
      'mature_leaf': '成葉',
      'old_leaf': '老葉',
      'healthy': '健康',
      'minor_damage': '軽微な損傷',
      'damaged': '損傷',
      'diseased': '病気',
      'today_summary': '今日の解析結果',
      'recent_results': '最近の解析結果',
      'analysis_complete': '解析が完了しました！',
      'save_success': '保存しました',
      'save_failed': '保存に失敗しました',
      'analysis_failed': '解析に失敗しました',
      'camera_error': 'カメラエラー',
      'model_loading': 'AIモデルを読み込み中...',
      'image_processing': '画像を処理中...',
      'high_confidence': '高い信頼度',
      'medium_confidence': '中程度の信頼度',
      'low_confidence': '低い信頼度',
      'camera_initializing': 'カメラを初期化中...',
      'capturing': '撮影中...',
      'moving_to_analysis': '解析画面へ移動中...',
      'place_leaf_center': '茶葉を画面の中央に配置してください',
      'analyzing_image': '画像を解析中...',
      'analysis_error': '解析エラー',
      'error_occurred': 'エラーが発生しました',
      'data_loading': 'データを読み込み中...',
      'save_result': '結果を保存',
      'comment_hint': 'この茶葉についてのコメントを入力してください',
      'save_result_success': '解析結果を保存しました',
      'save_result_failed': '保存に失敗しました',
      'unknown_state': '不明な状態',

      // Advanced analysis (AnalysisResultPage)
      'advanced_analysis': '高度な分析',
      'advanced_analysis_description': '複数の解析手法を組み合わせた高精度な分析を実行します',
      'run_advanced_analysis': '高度な分析を実行',
      'rerun_advanced_analysis': '高度な分析を再実行',

      // AppRouter fallback pages
      'router_unknown_route_title': '画面が見つかりません',
      'router_invalid_navigation_title': '画面遷移に失敗しました',
      'router_web_unsupported_title': '未サポート',
      'router_unknown_route_message': '不明な画面: {route}',
      'router_invalid_arguments_message': '引数が不正です: {route}（期待: {expected}）',
      'router_web_unsupported_message': 'Webでは未サポートです: {route}',
    },
  };

  /*
   * 翻訳データを型安全に正規化する
   * - json.decode の dynamic を Map<String, Map<String, String>> に落とし込む
   */
  static Map<String, Map<String, String>> _normalizeTranslations(
    Object? decoded,
  ) {
    final root = decoded;
    if (root is! Map) {
      return _fallbackTranslations;
    }

    final result = <String, Map<String, String>>{};

    for (final entry in root.entries) {
      final langKey = entry.key;
      final langValue = entry.value;
      if (langKey is! String) {
        continue;
      }
      if (langValue is! Map) {
        continue;
      }

      final normalizedLang = <String, String>{};
      for (final inner in langValue.entries) {
        final k = inner.key;
        final v = inner.value;
        if (k is String && v is String) {
          normalizedLang[k] = v;
        }
      }

      result[langKey] = normalizedLang;
    }

    if (result.isEmpty) {
      return _fallbackTranslations;
    }

    return result;
  }

  /// 翻訳データを読み込み
  Future<void> loadTranslations() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/translations/translations.json');
      _translations = _normalizeTranslations(json.decode(jsonString));

      // 保存された言語設定を読み込み
      final savedLanguage = getLocalStorage(_languageStorageKey);
      if (savedLanguage != null && _translations.containsKey(savedLanguage)) {
        _currentLanguage = savedLanguage;
      }
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.translationDataLoadError,
        e,
        stackTrace,
      );
      // フォールバック: assets 読み込みに失敗した場合の最小翻訳
      _translations = _fallbackTranslations;
    }
  }

  /// テスト用の翻訳データ読み込み
  /// 実際のファイルI/Oを行わず、メモリ内の翻訳データを直接設定
  @visibleForTesting
  Future<void> loadTranslationsForTest(
      [Map<String, dynamic>? translations]) async {
    if (translations == null) {
      _translations = _fallbackTranslations;
      return;
    }

    _translations = _normalizeTranslations(translations);
  }

  /// 言語を設定
  void setLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      // 言語設定をローカルストレージに保存
      setLocalStorage(_languageStorageKey, languageCode);
    }
  }

  /// 現在の言語を取得
  String get currentLanguage => _currentLanguage;

  /// 翻訳テキストを取得
  String translate(String key, {Map<String, dynamic>? params}) {
    try {
      final currentMap = _translations[_currentLanguage];
      final jaMap = _translations['ja'];
      String text = currentMap?[key] ?? jaMap?[key] ?? key;

      // パラメータ置換
      if (params != null) {
        params.forEach((key, value) {
          text = text.replaceAll('{$key}', value.toString());
        });
      }

      return text;
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        ErrorMessages.translationProcessError,
        e,
        stackTrace,
      );
      return key; // フォールバック
    }
  }

  /// 利用可能な言語リストを取得
  List<String> get availableLanguages => _translations.keys.toList();

  /// 言語名を取得
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }
}

/// 翻訳ヘルパー関数
String t(String key, {Map<String, dynamic>? params}) {
  return LocalizationService.instance.translate(key, params: params);
}

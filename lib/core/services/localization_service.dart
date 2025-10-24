import 'dart:convert';
import 'package:flutter/services.dart';

/**
 * 国際化サービスクラス
 * アプリケーションの多言語対応を管理
 */
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance =>
      _instance ??= LocalizationService._();

  LocalizationService._();

  Map<String, dynamic> _translations = {};
  String _currentLanguage = 'ja';

  /**
   * 翻訳データを読み込み
   */
  Future<void> loadTranslations() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/translations/translations.json');
      _translations = json.decode(jsonString);
    } catch (e) {
      // フォールバック: デフォルトの日本語翻訳
      _translations = {
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
          'low_confidence': '低い信頼度'
        }
      };
    }
  }

  /**
   * 言語を設定
   */
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }

  /**
   * 現在の言語を取得
   */
  String get currentLanguage => _currentLanguage;

  /**
   * 翻訳テキストを取得
   */
  String translate(String key, {Map<String, dynamic>? params}) {
    try {
      String text = _translations[_currentLanguage]?[key] ??
          _translations['ja']?[key] ??
          key;

      // パラメータ置換
      if (params != null) {
        params.forEach((key, value) {
          text = text.replaceAll('{$key}', value.toString());
        });
      }

      return text;
    } catch (e) {
      return key; // フォールバック
    }
  }

  /**
   * 利用可能な言語リストを取得
   */
  List<String> get availableLanguages => _translations.keys.toList();

  /**
   * 言語名を取得
   */
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

/**
 * 翻訳ヘルパー関数
 */
String t(String key, {Map<String, dynamic>? params}) {
  return LocalizationService.instance.translate(key, params: params);
}

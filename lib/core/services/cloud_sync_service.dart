import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/failures.dart';
import '../../features/tea_analysis/domain/entities/tea_analysis_result.dart';

/**
 * クラウド同期サービスのインターフェース
 */
abstract class CloudSyncService {
  Future<bool> isConnected();
  Future<void> syncToCloud(List<TeaAnalysisResult> results);
  Future<List<TeaAnalysisResult>> syncFromCloud();
  Future<void> enableAutoSync(bool enabled);
  Future<bool> isAutoSyncEnabled();
}

/**
 * クラウド同期サービスの実装
 * Firebase Firestore または REST API を使用
 */
class CloudSyncServiceImpl implements CloudSyncService {
  static const String _baseUrl = 'https://api.tea-garden-ai.com';
  static const String _syncEndpoint = '/api/v1/sync';
  static const String _authEndpoint = '/api/v1/auth';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _userIdKey = 'user_id';

  final http.Client _httpClient;
  final SharedPreferences _prefs;

  CloudSyncServiceImpl({
    required http.Client httpClient,
    required SharedPreferences prefs,
  })  : _httpClient = httpClient,
        _prefs = prefs;

  @override
  Future<bool> isConnected() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> syncToCloud(List<TeaAnalysisResult> results) async {
    if (!await isConnected()) {
      throw const ServerFailure('インターネット接続がありません');
    }

    try {
      final userId = await _getUserId();
      final lastSync = _prefs.getString(_lastSyncKey);

      // 最後の同期以降のデータのみを送信
      final filteredResults = _filterResultsSinceLastSync(results, lastSync);

      if (filteredResults.isEmpty) {
        return; // 同期するデータがない
      }

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl$_syncEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode({
          'userId': userId,
          'results': filteredResults.map((r) => _resultToJson(r)).toList(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // 同期成功時はタイムスタンプを更新
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      } else {
        throw ServerFailure('同期に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure('クラウド同期エラー: $e');
    }
  }

  @override
  Future<List<TeaAnalysisResult>> syncFromCloud() async {
    if (!await isConnected()) {
      throw const ServerFailure('インターネット接続がありません');
    }

    try {
      final userId = await _getUserId();
      final lastSync = _prefs.getString(_lastSyncKey);

      final response = await _httpClient.get(
        Uri.parse(
            '$_baseUrl$_syncEndpoint?userId=$userId&since=${lastSync ?? ''}'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data['results'] as List)
            .map((json) => _resultFromJson(json))
            .toList();

        // 同期成功時はタイムスタンプを更新
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        return results;
      } else {
        throw ServerFailure('同期に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure('クラウド同期エラー: $e');
    }
  }

  @override
  Future<void> enableAutoSync(bool enabled) async {
    await _prefs.setBool(_autoSyncKey, enabled);
  }

  @override
  Future<bool> isAutoSyncEnabled() async {
    return _prefs.getBool(_autoSyncKey) ?? false;
  }

  /**
   * ユーザーIDを取得または生成
   */
  Future<String> _getUserId() async {
    String? userId = _prefs.getString(_userIdKey);
    if (userId == null) {
      userId = _generateUserId();
      await _prefs.setString(_userIdKey, userId);
    }
    return userId;
  }

  /**
   * ユーザーIDを生成
   */
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'user_${timestamp}_$random';
  }

  /**
   * 認証トークンを取得
   */
  Future<String> _getAuthToken() async {
    // 簡易的な認証（実際の実装では適切な認証システムを使用）
    final userId = await _getUserId();
    return base64.encode(
        utf8.encode('$userId:${DateTime.now().millisecondsSinceEpoch}'));
  }

  /**
   * 最後の同期以降の結果をフィルタリング
   */
  List<TeaAnalysisResult> _filterResultsSinceLastSync(
    List<TeaAnalysisResult> results,
    String? lastSyncTimestamp,
  ) {
    if (lastSyncTimestamp == null) {
      return results; // 初回同期の場合は全てのデータを送信
    }

    final lastSync = DateTime.tryParse(lastSyncTimestamp);
    if (lastSync == null) {
      return results;
    }

    return results
        .where((result) => result.timestamp.isAfter(lastSync))
        .toList();
  }

  /**
   * TeaAnalysisResultをJSONに変換
   */
  Map<String, dynamic> _resultToJson(TeaAnalysisResult result) {
    return {
      'id': result.id,
      'imagePath': result.imagePath,
      'growthStage': result.growthStage,
      'healthStatus': result.healthStatus,
      'confidence': result.confidence,
      'comment': result.comment,
      'timestamp': result.timestamp.toIso8601String(),
    };
  }

  /**
   * JSONからTeaAnalysisResultに変換
   */
  TeaAnalysisResult _resultFromJson(Map<String, dynamic> json) {
    return TeaAnalysisResult(
      id: json['id'],
      imagePath: json['imagePath'],
      growthStage: json['growthStage'],
      healthStatus: json['healthStatus'],
      confidence: (json['confidence'] as num).toDouble(),
      comment: json['comment'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/**
 * オフライン同期キュー
 * ネットワークが利用できない場合のデータを管理
 */
class OfflineSyncQueue {
  static const String _queueKey = 'offline_sync_queue';
  final SharedPreferences _prefs;

  OfflineSyncQueue(this._prefs);

  /**
   * オフラインキューに追加
   */
  Future<void> addToQueue(TeaAnalysisResult result) async {
    final queue = await getQueue();
    queue.add(result);
    await _saveQueue(queue);
  }

  /**
   * オフラインキューを取得
   */
  Future<List<TeaAnalysisResult>> getQueue() async {
    final jsonString = _prefs.getString(_queueKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => _resultFromJson(json)).toList();
  }

  /**
   * オフラインキューをクリア
   */
  Future<void> clearQueue() async {
    await _prefs.remove(_queueKey);
  }

  /**
   * キューを保存
   */
  Future<void> _saveQueue(List<TeaAnalysisResult> queue) async {
    final jsonList = queue.map((result) => _resultToJson(result)).toList();
    await _prefs.setString(_queueKey, json.encode(jsonList));
  }

  /**
   * TeaAnalysisResultをJSONに変換
   */
  Map<String, dynamic> _resultToJson(TeaAnalysisResult result) {
    return {
      'id': result.id,
      'imagePath': result.imagePath,
      'growthStage': result.growthStage,
      'healthStatus': result.healthStatus,
      'confidence': result.confidence,
      'comment': result.comment,
      'timestamp': result.timestamp.toIso8601String(),
    };
  }

  /**
   * JSONからTeaAnalysisResultに変換
   */
  TeaAnalysisResult _resultFromJson(Map<String, dynamic> json) {
    return TeaAnalysisResult(
      id: json['id'],
      imagePath: json['imagePath'],
      growthStage: json['growthStage'],
      healthStatus: json['healthStatus'],
      confidence: (json['confidence'] as num).toDouble(),
      comment: json['comment'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/**
 * 同期状態管理
 */
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

/**
 * 同期状態の通知
 */
class SyncStatusNotifier extends ChangeNotifier {
  SyncStatus _status = SyncStatus.idle;
  String _message = '';
  int _pendingItems = 0;

  SyncStatus get status => _status;
  String get message => _message;
  int get pendingItems => _pendingItems;

  void setStatus(SyncStatus status,
      {String message = '', int pendingItems = 0}) {
    _status = status;
    _message = message;
    _pendingItems = pendingItems;
    notifyListeners();
  }

  void setSyncing({int pendingItems = 0}) {
    setStatus(SyncStatus.syncing,
        message: '同期中...', pendingItems: pendingItems);
  }

  void setSuccess({String message = '同期完了'}) {
    setStatus(SyncStatus.success, message: message);
  }

  void setError(String message) {
    setStatus(SyncStatus.error, message: message);
  }

  void setOffline() {
    setStatus(SyncStatus.offline, message: 'オフライン');
  }

  void setIdle() {
    setStatus(SyncStatus.idle);
  }
}

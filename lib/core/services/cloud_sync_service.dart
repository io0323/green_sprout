import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';
import '../../features/tea_analysis/domain/entities/tea_analysis_result.dart';
import '../utils/app_logger.dart';
import '../theme/tea_garden_theme.dart';

/// クラウド同期サービスのインターフェース
abstract class CloudSyncService {
  Future<bool> isConnected();
  Future<void> syncToCloud(List<TeaAnalysisResult> results);
  Future<List<TeaAnalysisResult>> syncFromCloud();
  Future<void> enableAutoSync(bool enabled);
  Future<bool> isAutoSyncEnabled();
}

/// クラウド同期サービスの実装
/// Firebase Firestore または REST API を使用
class CloudSyncServiceImpl implements CloudSyncService {
  final http.Client _httpClient;
  final SharedPreferences _prefs;

  CloudSyncServiceImpl({
    required http.Client httpClient,
    required SharedPreferences prefs,
  })  : _httpClient = httpClient,
        _prefs = prefs;

  /*
   * CloudSync用のHTTPヘッダーを生成する
   * - Authorization/Bearer と Content-Type(JSON) の生成ロジックを集約する
   */
  Future<Map<String, String>> _buildHeaders({
    required bool includeJsonContentType,
  }) async {
    final headers = <String, String>{
      HttpConstants.headerAuthorization:
          '${HttpConstants.bearerPrefix}${await _getAuthToken()}',
    };
    if (includeJsonContentType) {
      headers[HttpConstants.headerContentType] = HttpConstants.contentTypeJson;
    }
    return headers;
  }

  @override
  Future<bool> isConnected() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(
              '${CloudSyncConstants.baseUrl}${CloudSyncConstants.healthPath}',
            ),
            headers: HttpConstants.jsonContentTypeHeaders,
          )
          .timeout(AnimationConstants.fiveSeconds);

      return response.statusCode == HttpConstants.statusOk;
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        LogMessages.cloudSyncConnectionCheckError,
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> syncToCloud(List<TeaAnalysisResult> results) async {
    if (!await isConnected()) {
      throw const ServerFailure(ErrorMessages.cloudSyncNoInternet);
    }

    try {
      final userId = await _getUserId();
      final lastSync =
          _prefs.getString(CloudSyncConstants.keyLastSyncTimestamp);

      // 最後の同期以降のデータのみを送信
      final filteredResults = _filterResultsSinceLastSync(results, lastSync);

      if (filteredResults.isEmpty) {
        return; // 同期するデータがない
      }

      final response = await _httpClient.post(
        Uri.parse(
          '${CloudSyncConstants.baseUrl}'
          '${CloudSyncConstants.syncEndpointPath}',
        ),
        headers: await _buildHeaders(includeJsonContentType: true),
        body: json.encode({
          CloudSyncConstants.jsonKeyUserId: userId,
          CloudSyncConstants.jsonKeyResults:
              filteredResults.map((r) => _resultToJson(r)).toList(),
          CloudSyncConstants.jsonKeyTimestamp: DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == HttpConstants.statusOk) {
        // 同期成功時はタイムスタンプを更新
        await _prefs.setString(
          CloudSyncConstants.keyLastSyncTimestamp,
          DateTime.now().toIso8601String(),
        );
      } else {
        throw ServerFailure(
          '${ErrorMessages.cloudSyncFailedPrefix} ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        LogMessages.cloudSyncSendError,
        e,
        stackTrace,
      );
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure('${ErrorMessages.cloudSyncErrorPrefix} $e');
    }
  }

  @override
  Future<List<TeaAnalysisResult>> syncFromCloud() async {
    if (!await isConnected()) {
      throw const ServerFailure(ErrorMessages.cloudSyncNoInternet);
    }

    try {
      final userId = await _getUserId();
      final lastSync =
          _prefs.getString(CloudSyncConstants.keyLastSyncTimestamp);

      final uri = Uri.parse(
        '${CloudSyncConstants.baseUrl}${CloudSyncConstants.syncEndpointPath}',
      ).replace(
        queryParameters: {
          CloudSyncConstants.queryParamUserId: userId,
          CloudSyncConstants.queryParamSince: lastSync ?? '',
        },
      );

      final response = await _httpClient.get(
        uri,
        headers: await _buildHeaders(includeJsonContentType: false),
      );

      if (response.statusCode == HttpConstants.statusOk) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        final results = (data[CloudSyncConstants.jsonKeyResults] as List)
            .cast<Map<String, dynamic>>()
            .map(_resultFromJson)
            .toList();

        // 同期成功時はタイムスタンプを更新
        await _prefs.setString(
          CloudSyncConstants.keyLastSyncTimestamp,
          DateTime.now().toIso8601String(),
        );

        return results;
      } else {
        throw ServerFailure(
          '${ErrorMessages.cloudSyncFailedPrefix} ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        LogMessages.cloudSyncReceiveError,
        e,
        stackTrace,
      );
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure('${ErrorMessages.cloudSyncErrorPrefix} $e');
    }
  }

  @override
  Future<void> enableAutoSync(bool enabled) async {
    await _prefs.setBool(CloudSyncConstants.keyAutoSyncEnabled, enabled);
  }

  @override
  Future<bool> isAutoSyncEnabled() async {
    return _prefs.getBool(CloudSyncConstants.keyAutoSyncEnabled) ?? false;
  }

  /// ユーザーIDを取得または生成
  Future<String> _getUserId() async {
    String? userId = _prefs.getString(CloudSyncConstants.keyUserId);
    if (userId == null) {
      userId = _generateUserId();
      await _prefs.setString(CloudSyncConstants.keyUserId, userId);
    }
    return userId;
  }

  /// ユーザーIDを生成
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'user_${timestamp}_$random';
  }

  /// 認証トークンを取得
  Future<String> _getAuthToken() async {
    // 簡易的な認証（実際の実装では適切な認証システムを使用）
    final userId = await _getUserId();
    return base64.encode(
        utf8.encode('$userId:${DateTime.now().millisecondsSinceEpoch}'));
  }

  /// 最後の同期以降の結果をフィルタリング
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

  /// TeaAnalysisResultをJSONに変換
  Map<String, dynamic> _resultToJson(TeaAnalysisResult result) {
    return {
      'id': result.id,
      'imagePath': result.imagePath,
      'growthStage': result.growthStage,
      'healthStatus': result.healthStatus,
      'confidence': result.confidence,
      'comment': result.comment,
      CloudSyncConstants.jsonKeyTimestamp: result.timestamp.toIso8601String(),
    };
  }

  /// JSONからTeaAnalysisResultに変換
  TeaAnalysisResult _resultFromJson(Map<String, dynamic> json) {
    return TeaAnalysisResult(
      id: json['id'],
      imagePath: json['imagePath'],
      growthStage: json['growthStage'],
      healthStatus: json['healthStatus'],
      confidence: (json['confidence'] as num).toDouble(),
      comment: json['comment'],
      timestamp: DateTime.parse(json[CloudSyncConstants.jsonKeyTimestamp]),
    );
  }
}

/// オフライン同期キュー
/// ネットワークが利用できない場合のデータを管理
class OfflineSyncQueue {
  final SharedPreferences _prefs;

  OfflineSyncQueue(this._prefs);

  /// オフラインキューに追加
  Future<void> addToQueue(TeaAnalysisResult result) async {
    final queue = await getQueue();
    queue.add(result);
    await _saveQueue(queue);
  }

  /// オフラインキューを取得
  Future<List<TeaAnalysisResult>> getQueue() async {
    final jsonString = _prefs.getString(CloudSyncConstants.keyOfflineSyncQueue);
    if (jsonString == null) return [];

    final jsonList =
        (json.decode(jsonString) as List).cast<Map<String, dynamic>>();
    return jsonList.map(_resultFromJson).toList();
  }

  /// オフラインキューをクリア
  Future<void> clearQueue() async {
    await _prefs.remove(CloudSyncConstants.keyOfflineSyncQueue);
  }

  /// キューを保存
  Future<void> _saveQueue(List<TeaAnalysisResult> queue) async {
    final jsonList = queue.map((result) => _resultToJson(result)).toList();
    await _prefs.setString(
      CloudSyncConstants.keyOfflineSyncQueue,
      json.encode(jsonList),
    );
  }

  /// TeaAnalysisResultをJSONに変換
  Map<String, dynamic> _resultToJson(TeaAnalysisResult result) {
    return {
      'id': result.id,
      'imagePath': result.imagePath,
      'growthStage': result.growthStage,
      'healthStatus': result.healthStatus,
      'confidence': result.confidence,
      'comment': result.comment,
      CloudSyncConstants.jsonKeyTimestamp: result.timestamp.toIso8601String(),
    };
  }

  /// JSONからTeaAnalysisResultに変換
  TeaAnalysisResult _resultFromJson(Map<String, dynamic> json) {
    return TeaAnalysisResult(
      id: json['id'],
      imagePath: json['imagePath'],
      growthStage: json['growthStage'],
      healthStatus: json['healthStatus'],
      confidence: (json['confidence'] as num).toDouble(),
      comment: json['comment'],
      timestamp: DateTime.parse(json[CloudSyncConstants.jsonKeyTimestamp]),
    );
  }
}

/// 同期状態管理
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// 同期状態の通知
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

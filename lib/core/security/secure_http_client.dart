import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// セキュアなHTTPクライアント
/// セキュリティを強化したHTTP通信を提供
class SecureHttpClient {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  late http.Client _client;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'User-Agent': 'TeaGardenAI/1.0.0',
  };

  SecureHttpClient() {
    _client = http.Client();
  }

  /// GETリクエストを送信する
  /// @param url URL
  /// @param headers ヘッダー
  /// @param timeout タイムアウト
  /// @return レスポンス
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () => _client.get(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      ),
      timeout: timeout,
    );
  }

  /// POSTリクエストを送信する
  /// @param url URL
  /// @param body ボディ
  /// @param headers ヘッダー
  /// @param timeout タイムアウト
  /// @return レスポンス
  Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () => _client.post(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  /// PUTリクエストを送信する
  /// @param url URL
  /// @param body ボディ
  /// @param headers ヘッダー
  /// @param timeout タイムアウト
  /// @return レスポンス
  Future<http.Response> put(
    String url, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () => _client.put(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  /// DELETEリクエストを送信する
  /// @param url URL
  /// @param headers ヘッダー
  /// @param timeout タイムアウト
  /// @return レスポンス
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () => _client.delete(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      ),
      timeout: timeout,
    );
  }

  /// ファイルをアップロードする
  /// @param url URL
  /// @param file ファイル
  /// @param fieldName フィールド名
  /// @param headers ヘッダー
  /// @param timeout タイムアウト
  /// @return レスポンス
  Future<http.Response> uploadFile(
    String url,
    File file,
    String fieldName, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // ヘッダーを追加
    request.headers.addAll({..._defaultHeaders, ...?headers});

    // ファイルを追加
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    return await _makeRequest(
      () => request.send(),
      timeout: timeout,
    );
  }

  /// リクエストを実行する（リトライ機能付き）
  /// @param requestFunction リクエスト関数
  /// @param timeout タイムアウト
  /// @return レスポンス
  Future<http.Response> _makeRequest(
    Future<dynamic> Function() requestFunction, {
    Duration? timeout,
  }) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < _maxRetries) {
      try {
        final response = await requestFunction().timeout(
          timeout ?? _defaultTimeout,
        );

        // MultipartRequestの場合はResponseに変換
        if (response is http.StreamedResponse) {
          final body = await response.stream.bytesToString();
          return http.Response(
            body,
            response.statusCode,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase,
          );
        }

        return response as http.Response;
      } on TimeoutException {
        lastException = TimeoutException('Request timeout');
        retryCount++;
        if (retryCount < _maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      } on SocketException {
        lastException = SocketException('Network error');
        retryCount++;
        if (retryCount < _maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      } on HttpException {
        lastException = HttpException('HTTP error');
        retryCount++;
        if (retryCount < _maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      } catch (e) {
        lastException = Exception('Unexpected error: $e');
        retryCount++;
        if (retryCount < _maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }

    throw lastException ?? Exception('Max retries exceeded');
  }

  /// レスポンスを検証する
  /// @param response レスポンス
  /// @return 検証結果
  bool _validateResponse(http.Response response) {
    // ステータスコードの検証
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    // コンテンツタイプの検証
    // NOTE: Removed restrictive content-type check to allow non-JSON responses.

    // レスポンスサイズの検証（10MB制限）
    if (response.bodyBytes.length > 10 * 1024 * 1024) {
      return false;
    }

    return true;
  }

  /// クライアントを閉じる
  void close() {
    _client.close();
  }

  /// デストラクタ
  void dispose() {
    close();
  }
}

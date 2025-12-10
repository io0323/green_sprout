import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import '../theme/tea_garden_theme.dart';

/// パフォーマンス監視とメモリ管理のユーティリティクラス
class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final List<String> _memoryLogs = [];

  /// パフォーマンス測定を開始
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// パフォーマンス測定を終了
  static Duration stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;
      _timers.remove(name);

      AppLogger.debug('⏱️ $name: ${duration.inMilliseconds}ms');

      return duration;
    }
    return Duration.zero;
  }

  /// 現在のメモリ使用量を取得
  static double getCurrentMemoryUsage() {
    final memoryInfo = ProcessInfo.currentRss;
    return memoryInfo.toDouble();
  }

  /// メモリ使用量をログに記録
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      final memoryInfo = ProcessInfo.currentRss;
      final memoryMB = memoryInfo / (1024 * 1024);
      _memoryLogs.add('$context: ${memoryMB.toStringAsFixed(2)}MB');

      if (_memoryLogs.length > 100) {
        _memoryLogs.removeAt(0); // 古いログを削除
      }

      AppLogger.debug('🧠 Memory $context: ${memoryMB.toStringAsFixed(2)}MB');
    }
  }

  /// メモリログを取得
  static List<String> getMemoryLogs() => List.unmodifiable(_memoryLogs);

  /// メモリログをクリア
  static void clearMemoryLogs() {
    _memoryLogs.clear();
  }

  /// 非同期処理のデバウンス
  static Timer? _debounceTimer;

  static void debounce(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// 画像のメモリ効率的な読み込み
  static Future<Uint8List?> loadImageBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();

      // メモリ使用量をログ
      logMemoryUsage('Image loaded: ${path.split('/').last}');

      return bytes;
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        '画像読み込みエラー',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// 大きなリストのページネーション
  static List<T> paginateList<T>(
    List<T> list,
    int page,
    int pageSize,
  ) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, list.length);

    if (startIndex >= list.length) return [];

    return list.sublist(startIndex, endIndex);
  }

  /// メモリリークの検出
  static void detectMemoryLeaks() {
    if (kDebugMode) {
      final currentMemory = ProcessInfo.currentRss / (1024 * 1024);

      if (currentMemory > 200) {
        // 200MB以上で警告
        AppLogger.debugWarning(
            'High memory usage detected: ${currentMemory.toStringAsFixed(2)}MB');
        AppLogger.debug('📊 Recent memory logs:');
        for (final log in _memoryLogs.length > 10
            ? _memoryLogs.sublist(_memoryLogs.length - 10)
            : _memoryLogs) {
          AppLogger.debug('   $log');
        }
      }
    }
  }

  /// パフォーマンス統計を取得
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'active_timers': _timers.length,
      'memory_logs_count': _memoryLogs.length,
      'current_memory_mb':
          (ProcessInfo.currentRss / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}

/// 画像キャッシュ管理クラス
class ImageCacheManager {
  static final Map<String, Uint8List> _cache = {};
  static const int _maxCacheSize = 50; // 最大50枚までキャッシュ

  /// 画像をキャッシュから取得
  static Uint8List? getCachedImage(String key) {
    return _cache[key];
  }

  /// 画像をキャッシュに保存
  static void cacheImage(String key, Uint8List bytes) {
    // キャッシュサイズ制限
    if (_cache.length >= _maxCacheSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }

    _cache[key] = bytes;

    if (kDebugMode) {
      AppLogger.debug('📸 Cached image: $key (${bytes.length} bytes)');
    }
  }

  /// キャッシュをクリア
  static void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      AppLogger.debug('🗑️ Image cache cleared');
    }
  }

  /// キャッシュ統計を取得
  static Map<String, dynamic> getCacheStats() {
    final totalSize = _cache.values.fold<int>(
      0,
      (sum, bytes) => sum + bytes.length,
    );

    return {
      'cached_images': _cache.length,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}

/// データベース接続プール管理
class DatabaseConnectionPool {
  static final List<DatabaseConnection> _connections = [];
  static const int _maxConnections = 5;

  /// データベース接続を取得
  static Future<DatabaseConnection> getConnection() async {
    // 既存の接続を再利用
    for (final connection in _connections) {
      if (!connection.isInUse) {
        connection.isInUse = true;
        return connection;
      }
    }

    // 新しい接続を作成
    if (_connections.length < _maxConnections) {
      final connection = DatabaseConnection();
      await connection.initialize();
      connection.isInUse = true;
      _connections.add(connection);
      return connection;
    }

    // 接続プールが満杯の場合は待機
    return await _waitForConnection();
  }

  /// 接続の解放
  static void releaseConnection(DatabaseConnection connection) {
    connection.isInUse = false;
  }

  /// 接続を待機
  static Future<DatabaseConnection> _waitForConnection() async {
    while (true) {
      for (final connection in _connections) {
        if (!connection.isInUse) {
          connection.isInUse = true;
          return connection;
        }
      }
      await Future.delayed(AnimationConstants.extraShortDuration);
    }
  }

  /// 全接続を閉じる
  static Future<void> closeAllConnections() async {
    for (final connection in _connections) {
      await connection.close();
    }
    _connections.clear();
  }
}

/// データベース接続クラス（モック）
class DatabaseConnection {
  bool isInUse = false;

  Future<void> initialize() async {
    // データベース接続の初期化
    await Future.delayed(AnimationConstants.extraShortDuration);
  }

  Future<void> close() async {
    // データベース接続の終了
    await Future.delayed(AnimationConstants.veryShortDuration);
  }
}

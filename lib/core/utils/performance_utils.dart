import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import '../constants/app_constants.dart';
import '../theme/tea_garden_theme.dart';

/// パフォーマンス監視とメモリ管理のユーティリティクラス
class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final Queue<String> _memoryLogs = Queue();

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

      AppLogger.debug(
        '${PerformanceLogMessages.timerPrefix} '
        '$name: ${duration.inMilliseconds}${PerformanceLogMessages.timeUnitMilliseconds}',
      );

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
      final memoryMB = memoryInfo / PerformanceConstants.bytesPerMegabyte;
      _memoryLogs.add(
        '$context: ${memoryMB.toStringAsFixed(2)}'
        '${PerformanceLogMessages.memoryUnitMb}',
      );

      if (_memoryLogs.length > PerformanceConstants.memoryLogMaxEntries) {
        _memoryLogs.removeFirst(); // 古いログを削除
      }

      AppLogger.debug(
        '${PerformanceLogMessages.memoryPrefix} '
        '$context: ${memoryMB.toStringAsFixed(2)}'
        '${PerformanceLogMessages.memoryUnitMb}',
      );
    }
  }

  /// メモリログを取得
  static List<String> getMemoryLogs() =>
      List.unmodifiable(_memoryLogs.toList());

  /// メモリログをクリア
  static void clearMemoryLogs() {
    _memoryLogs.clear();
  }

  /// 非同期処理のデバウンス
  ///
  /// `key` ごとに独立してデバウンスできるようにすることで、
  /// 無関係な処理同士のタイマーキャンセルを防ぐ。
  static final Map<String, Timer> _debounceTimers = {};

  static void debounce(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, () {
      _debounceTimers.remove(key);
      callback();
    });
  }

  /// 画像のメモリ効率的な読み込み
  static Future<Uint8List?> loadImageBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();

      // メモリ使用量をログ
      logMemoryUsage(
        '${PerformanceLogMessages.imageLoadedPrefix} ${path.split('/').last}',
      );

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
      final currentMemory =
          ProcessInfo.currentRss / PerformanceConstants.bytesPerMegabyte;

      if (currentMemory > PerformanceConstants.memoryWarningThresholdMb) {
        // 閾値以上で警告
        AppLogger.debugWarning(
          '${PerformanceLogMessages.highMemoryUsageDetected} '
          '${currentMemory.toStringAsFixed(2)}'
          '${PerformanceLogMessages.memoryUnitMb}',
        );
        AppLogger.debug(PerformanceLogMessages.recentMemoryLogsHeader);
        final logs = _memoryLogs.toList(growable: false);
        final startIndex =
            logs.length > PerformanceConstants.memoryRecentLogsMaxEntries
                ? logs.length - PerformanceConstants.memoryRecentLogsMaxEntries
                : 0;
        for (final log in logs.sublist(startIndex)) {
          AppLogger.debug(
              '${PerformanceLogMessages.recentMemoryLogIndent}$log');
        }
      }
    }
  }

  /// パフォーマンス統計を取得
  static Map<String, dynamic> getPerformanceStats() {
    return {
      PerformanceStatsKeys.activeTimers: _timers.length,
      PerformanceStatsKeys.memoryLogsCount: _memoryLogs.length,
      PerformanceStatsKeys.currentMemoryMb:
          (ProcessInfo.currentRss / PerformanceConstants.bytesPerMegabyte)
              .toStringAsFixed(2),
    };
  }
}

/// 画像キャッシュ管理クラス
class ImageCacheManager {
  static final Map<String, Uint8List> _cache = {};
  static const int _maxCacheSize =
      PerformanceConstants.imageCacheMaxEntries; // 最大枚数

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
      AppLogger.debug(
        '${PerformanceLogMessages.imageCacheEntryPrefix} '
        '$key (${bytes.length} bytes)',
      );
    }
  }

  /// キャッシュをクリア
  static void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      AppLogger.debug(PerformanceLogMessages.imageCacheCleared);
    }
  }

  /// キャッシュ統計を取得
  static Map<String, dynamic> getCacheStats() {
    final totalSize = _cache.values.fold<int>(
      0,
      (sum, bytes) => sum + bytes.length,
    );

    return {
      PerformanceStatsKeys.cachedImages: _cache.length,
      PerformanceStatsKeys.totalSizeBytes: totalSize,
      PerformanceStatsKeys.totalSizeMb:
          (totalSize / PerformanceConstants.bytesPerMegabyte)
              .toStringAsFixed(2),
    };
  }
}

/// データベース接続プール管理
class DatabaseConnectionPool {
  static final List<DatabaseConnection> _connections = [];
  static const int _maxConnections =
      PerformanceConstants.maxDatabaseConnections;
  static final Queue<Completer<DatabaseConnection>> _waiters = Queue();

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
    /*
     * 待機中の要求がある場合は、解放された接続を即時に割り当てる。
     * busy-wait を避けて無駄なポーリングを削減する。
     */
    if (_waiters.isNotEmpty) {
      final waiter = _waiters.removeFirst();
      connection.isInUse = true;
      if (!waiter.isCompleted) {
        waiter.complete(connection);
      }
      return;
    }

    connection.isInUse = false;
  }

  /// 接続を待機
  static Future<DatabaseConnection> _waitForConnection() async {
    /*
     * 接続が解放されるまで待機（releaseConnectionで通知される）。
     */
    final completer = Completer<DatabaseConnection>();
    _waiters.addLast(completer);
    return completer.future;
  }

  /// 全接続を閉じる
  static Future<void> closeAllConnections() async {
    /*
     * クローズ時に待機中がいる場合、待機を解除してデッドロックを防ぐ。
     */
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) {
        waiter.completeError(StateError('Connection pool closed'));
      }
    }
    _waiters.clear();

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

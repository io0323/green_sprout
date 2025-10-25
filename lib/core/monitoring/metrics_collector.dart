import 'package:flutter/foundation.dart';
import 'package:tea_garden_ai/core/utils/performance_utils.dart';

/// メトリクス収集サービス
/// アプリケーションのパフォーマンスメトリクスを収集・分析
class MetricsCollector {
  static final MetricsCollector _instance = MetricsCollector._internal();
  factory MetricsCollector() => _instance;
  MetricsCollector._internal();

  final List<MetricData> _metrics = [];
  final Map<String, Timer> _timers = {};
  // Previously, PerformanceUtils was instantiated as an object for each MetricsCollector.
  // It is now used statically to simplify usage and avoid unnecessary object creation,
  // since all its methods are static and do not require instance state.

  /// メトリクスを記録する
  /// @param name メトリクス名
  /// @param value 値
  /// @param unit 単位
  /// @param tags タグ
  void recordMetric(
    String name,
    double value, {
    String unit = 'count',
    Map<String, String>? tags,
  }) {
    final metric = MetricData(
      name: name,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      tags: tags ?? {},
    );

    _metrics.add(metric);

    if (kDebugMode) {
      debugPrint('Metric recorded: $name = $value $unit');
    }
  }

  /// カウンターメトリクスを増加させる
  /// @param name メトリクス名
  /// @param increment 増加値
  /// @param tags タグ
  void incrementCounter(
    String name, {
    double increment = 1.0,
    Map<String, String>? tags,
  }) {
    recordMetric(name, increment, unit: 'count', tags: tags);
  }

  /// ゲージメトリクスを設定する
  /// @param name メトリクス名
  /// @param value 値
  /// @param tags タグ
  void setGauge(
    String name,
    double value, {
    Map<String, String>? tags,
  }) {
    recordMetric(name, value, unit: 'gauge', tags: tags);
  }

  /// タイマーを開始する
  /// @param name タイマー名
  /// @param tags タグ
  void startTimer(String name, {Map<String, String>? tags}) {
    PerformanceUtils.startTimer(name);
    _timers[name] = Timer(name, tags: tags);
  }

  /// タイマーを停止する
  /// @param name タイマー名
  /// @return 経過時間（ミリ秒）
  double stopTimer(String name) {
    final duration = PerformanceUtils.stopTimer(name);
    final timer = _timers.remove(name);

    if (timer != null) {
      recordMetric(
        'timer.$name',
        duration.inMilliseconds.toDouble(),
        unit: 'milliseconds',
        tags: timer.tags,
      );
    }

    return duration.inMilliseconds.toDouble();
  }

  /// メモリ使用量を記録する
  /// @param operation 操作名
  void recordMemoryUsage(String operation) {
    final memoryUsage = PerformanceUtils.getCurrentMemoryUsage();
    recordMetric(
      'memory.usage',
      memoryUsage,
      unit: 'bytes',
      tags: {'operation': operation},
    );

    PerformanceUtils.logMemoryUsage(operation);
  }

  /// エラーを記録する
  /// @param error エラー
  /// @param context コンテキスト
  void recordError(dynamic error, {String? context}) {
    incrementCounter(
      'errors.total',
      tags: {
        'error_type': error.runtimeType.toString(),
        'context': context ?? 'unknown',
      },
    );

    if (kDebugMode) {
      debugPrint('Error recorded: $error (context: $context)');
    }
  }

  /// ユーザーアクションを記録する
  /// @param action アクション
  /// @param details 詳細
  void recordUserAction(String action, {Map<String, dynamic>? details}) {
    incrementCounter(
      'user.actions',
      tags: {'action': action},
    );

    if (details != null) {
      details.forEach((key, value) {
        recordMetric(
          'user.action.$action.$key',
          value is num ? value.toDouble() : 0.0,
          tags: {'action': action, 'detail': key},
        );
      });
    }
  }

  /// ネットワークリクエストを記録する
  /// @param url URL
  /// @param method HTTPメソッド
  /// @param statusCode ステータスコード
  /// @param duration 処理時間
  /// @param responseSize レスポンスサイズ
  void recordNetworkRequest(
    String url,
    String method,
    int statusCode,
    double duration,
    int responseSize,
  ) {
    recordMetric(
      'network.request.duration',
      duration,
      unit: 'milliseconds',
      tags: {
        'method': method,
        'status_code': statusCode.toString(),
        'url': _sanitizeUrl(url),
      },
    );

    recordMetric(
      'network.request.size',
      responseSize.toDouble(),
      unit: 'bytes',
      tags: {
        'method': method,
        'url': _sanitizeUrl(url),
      },
    );

    incrementCounter(
      'network.requests.total',
      tags: {
        'method': method,
        'status_code': statusCode.toString(),
      },
    );
  }

  /// データベース操作を記録する
  /// @param operation 操作
  /// @param table テーブル
  /// @param duration 処理時間
  /// @param recordCount レコード数
  void recordDatabaseOperation(
    String operation,
    String table,
    double duration,
    int recordCount,
  ) {
    recordMetric(
      'database.operation.duration',
      duration,
      unit: 'milliseconds',
      tags: {
        'operation': operation,
        'table': table,
      },
    );

    recordMetric(
      'database.operation.records',
      recordCount.toDouble(),
      unit: 'count',
      tags: {
        'operation': operation,
        'table': table,
      },
    );
  }

  /// メトリクスを取得する
  /// @param name メトリクス名（オプション）
  /// @param tags タグフィルター（オプション）
  /// @return メトリクスリスト
  List<MetricData> getMetrics({
    String? name,
    Map<String, String>? tags,
  }) {
    var filteredMetrics = _metrics;

    if (name != null) {
      filteredMetrics = filteredMetrics
          .where((metric) => metric.name.contains(name))
          .toList();
    }

    if (tags != null) {
      filteredMetrics = filteredMetrics.where((metric) {
        return tags.entries
            .every((entry) => metric.tags[entry.key] == entry.value);
      }).toList();
    }

    return filteredMetrics;
  }

  /// メトリクス統計を取得する
  /// @param name メトリクス名
  /// @param tags タグフィルター（オプション）
  /// @return 統計情報
  MetricStatistics getMetricStatistics(
    String name, {
    Map<String, String>? tags,
  }) {
    final metrics = getMetrics(name: name, tags: tags);

    if (metrics.isEmpty) {
      return MetricStatistics(
        count: 0,
        sum: 0.0,
        average: 0.0,
        min: 0.0,
        max: 0.0,
      );
    }

    final values = metrics.map((m) => m.value).toList();
    values.sort();

    return MetricStatistics(
      count: values.length,
      sum: values.reduce((a, b) => a + b),
      average: values.reduce((a, b) => a + b) / values.length,
      min: values.first,
      max: values.last,
    );
  }

  /// メトリクスをクリアする
  void clearMetrics() {
    _metrics.clear();
    _timers.clear();
  }

  /// メトリクスレポートを生成する
  /// @return レポート文字列
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== Metrics Report ===');
    buffer.writeln('Total metrics: ${_metrics.length}');
    buffer.writeln('Active timers: ${_timers.length}');
    buffer.writeln();

    // メトリクス名ごとの統計
    final metricNames = _metrics.map((m) => m.name).toSet();
    for (final name in metricNames) {
      final stats = getMetricStatistics(name);
      buffer.writeln('$name:');
      buffer.writeln('  Count: ${stats.count}');
      buffer.writeln('  Sum: ${stats.sum.toStringAsFixed(2)}');
      buffer.writeln('  Average: ${stats.average.toStringAsFixed(2)}');
      buffer.writeln('  Min: ${stats.min.toStringAsFixed(2)}');
      buffer.writeln('  Max: ${stats.max.toStringAsFixed(2)}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// URLをサニタイズする
  /// @param url URL
  /// @return サニタイズされたURL
  String _sanitizeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}${uri.path}';
    } catch (e) {
      return 'invalid_url';
    }
  }
}

/// メトリクスデータクラス
class MetricData {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, String> tags;

  MetricData({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
    };
  }
}

/// タイマークラス
class Timer {
  final String name;
  final Map<String, String> tags;
  final DateTime startTime;

  Timer(this.name, {Map<String, String>? tags})
      : tags = tags ?? {},
        startTime = DateTime.now();
}

/// メトリクス統計クラス
class MetricStatistics {
  final int count;
  final double sum;
  final double average;
  final double min;
  final double max;

  MetricStatistics({
    required this.count,
    required this.sum,
    required this.average,
    required this.min,
    required this.max,
  });
}

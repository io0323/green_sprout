import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';
import 'package:tea_garden_ai/core/monitoring/metrics_collector.dart';

/*
 * MetricsCollector の保持上限（リングバッファ）回帰テスト
 * - maxMetricEntries を超えたときに古いデータが削除されることを検証する
 */
void main() {
  group('MetricsCollector buffer limit', () {
    test('maxMetricEntries超過時に先頭から削除される', () {
      final collector = MetricsCollector();
      collector.clearMetrics();

      /*
       * max + 2件記録する（0,1が落ちて先頭が2になる想定）
       */
      const total = MetricsConstants.maxMetricEntries + 2;
      for (var i = 0; i < total; i += 1) {
        collector.recordMetric('test.metric', i.toDouble());
      }

      final metrics = collector.getMetrics(name: 'test.metric');
      expect(metrics.length, MetricsConstants.maxMetricEntries);
      expect(metrics.first.value, 2.0);
      expect(metrics.last.value, (total - 1).toDouble());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/monitoring/metrics_collector.dart';

/* getMetrics() の返り値が読み取り専用であることを保証する回帰テスト */
void main() {
  group('MetricsCollector.getMetrics', () {
    late MetricsCollector collector;

    setUp(() {
      collector = MetricsCollector();
      collector.clearMetrics();
    });

    test('フィルタ無しの場合、返り値はunmodifiableである', () {
      collector.recordMetric('test.metric', 1.0);

      final metrics = collector.getMetrics();

      expect(
        () => metrics.add(
          MetricData(
            name: 'should.fail',
            value: 999.0,
            unit: 'count',
            timestamp: DateTime.now(),
            tags: const {},
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}

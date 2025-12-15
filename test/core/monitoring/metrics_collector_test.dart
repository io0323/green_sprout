import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/monitoring/metrics_collector.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';

/*
 * MetricsCollector のユニットテスト
 * - generateReport の統計（Count/Sum/Average）が正しいことを確認し、
 *   レポート集計の回帰（二重加算など）を防止する。
 */
void main() {
  group('MetricsCollector', () {
    test('generateReport: 統計が二重加算されない', () {
      final collector = MetricsCollector();
      collector.clearMetrics();

      /*
       * 同じ名前のメトリクスを複数回記録し、集計結果が正しいことを確認する。
       */
      collector.recordMetric('test.metric', 1.0);
      collector.recordMetric('test.metric', 2.0);
      collector.recordMetric('test.metric', 3.0);

      final report = collector.generateReport();
      expect(report, contains('test.metric:'));
      expect(
        report,
        contains('  ${MetricsMessages.reportCountLabel}: 3'),
      );
      expect(
        report,
        contains(
          '  ${MetricsMessages.reportSumLabel}: 6.00',
        ),
      );
      expect(
        report,
        contains(
          '  ${MetricsMessages.reportAverageLabel}: 2.00',
        ),
      );
    });
  });
}

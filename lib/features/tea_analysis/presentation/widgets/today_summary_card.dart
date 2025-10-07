import 'package:flutter/material.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/tea_analysis_result.dart';

/**
 * 今日のサマリーカードウィジェット
 * 再利用可能なUIコンポーネント
 */
class TodaySummaryCard extends StatelessWidget {
  final List<TeaAnalysisResult> results;

  const TodaySummaryCard({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayResults = results.where((result) {
      return result.createdAt.year == today.year &&
             result.createdAt.month == today.month &&
             result.createdAt.day == today.day;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日の解析結果',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${todayResults.length}件の解析を実行しました',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (todayResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '最新: ${todayResults.first.growthStage} - ${todayResults.first.healthStatus}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

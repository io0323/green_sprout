import 'package:flutter/material.dart';
import '../../domain/entities/wearable_analysis_result.dart';
import '../../../../core/utils/platform_utils.dart';

/// ウェアラブルデバイス用の解析結果カード
/// コンパクトな表示で重要な情報のみを表示
class WearableResultCard extends StatelessWidget {
  final WearableAnalysisResult result;

  const WearableResultCard({
    super.key,
    required this.result,
  });

  /// 健康状態の色を取得
  Color _getHealthStatusColor(String status) {
    switch (status) {
      case '健康':
        return Colors.green;
      case '軽微な損傷':
        return Colors.yellow[700]!;
      case '損傷':
        return Colors.orange;
      case '病気':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 成長段階のアイコンを取得
  IconData _getGrowthStageIcon(String stage) {
    switch (stage) {
      case '芽':
        return Icons.eco;
      case '若葉':
        return Icons.nature;
      case '成葉':
        return Icons.park;
      case '老葉':
        return Icons.forest;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWearable = PlatformUtils.isWearable;
    final healthColor = _getHealthStatusColor(result.healthStatus);
    final growthIcon = _getGrowthStageIcon(result.growthStage);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWearable ? 8.0 : 12.0),
        child: Row(
          children: [
            // 成長段階アイコン
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                growthIcon,
                size: isWearable ? 20 : 24,
                color: Colors.green[800],
              ),
            ),

            const SizedBox(width: 12),

            // 情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.growthStage,
                    style: TextStyle(
                      fontSize: isWearable ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: healthColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        result.healthStatus,
                        style: TextStyle(
                          fontSize: isWearable ? 10 : 12,
                          color: healthColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 信頼度
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(result.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: isWearable ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  '信頼度',
                  style: TextStyle(
                    fontSize: isWearable ? 8 : 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

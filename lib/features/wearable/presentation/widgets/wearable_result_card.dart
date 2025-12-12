import 'package:flutter/material.dart';
import '../../domain/entities/wearable_analysis_result.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// ウェアラブルデバイス用の解析結果カード
/// コンパクトな表示で重要な情報のみを表示
class WearableResultCard extends StatelessWidget {
  final WearableAnalysisResult result;

  const WearableResultCard({
    super.key,
    required this.result,
  });

  /// 健康状態の色を取得
  /// テーマの色を使用して意味的な色を返す
  Color _getHealthStatusColor(String status) {
    switch (status) {
      case '健康':
        return TeaGardenTheme.successColor;
      case '軽微な損傷':
        return TeaGardenTheme.warningColor;
      case '損傷':
        return TeaGardenTheme.warningColor;
      case '病気':
        return TeaGardenTheme.errorColor;
      default:
        return TeaGardenTheme.infoColor;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final healthColor = _getHealthStatusColor(result.healthStatus);
    final growthIcon = _getGrowthStageIcon(result.growthStage);

    return Card(
      elevation: TeaGardenTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isWearable ? TeaGardenTheme.spacingS : TeaGardenTheme.spacingM,
        ),
        child: Row(
          children: [
            // 成長段階アイコン
            Container(
              padding: const EdgeInsets.all(TeaGardenTheme.spacingS),
              decoration: BoxDecoration(
                color: colorScheme.primary
                    .withOpacity(TeaGardenTheme.opacityVeryLow),
                shape: BoxShape.circle,
              ),
              child: Icon(
                growthIcon,
                size: isWearable
                    ? TeaGardenTheme.iconSizeWearableSmall
                    : TeaGardenTheme.iconSizeDefaultSmall,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(width: TeaGardenTheme.spacingM),

            // 情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.growthStage,
                    style: TextStyle(
                      fontSize: isWearable
                          ? TeaGardenTheme.wearableFontSizeSmall
                          : TeaGardenTheme.bodyMedium.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TeaGardenTheme.spacingXS),
                  Row(
                    children: [
                      Container(
                        width: TeaGardenTheme.spacingS,
                        height: TeaGardenTheme.spacingS,
                        decoration: BoxDecoration(
                          color: healthColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: TeaGardenTheme.spacingXS),
                      Text(
                        result.healthStatus,
                        style: TextStyle(
                          fontSize: isWearable
                              ? TeaGardenTheme.wearableFontSizeSmall
                              : TeaGardenTheme.bodySmall.fontSize,
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
                    fontSize: isWearable
                        ? TeaGardenTheme.wearableFontSizeSmall
                        : TeaGardenTheme.bodyMedium.fontSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  '信頼度',
                  style: TextStyle(
                    fontSize: isWearable
                        ? TeaGardenTheme.wearableFontSizeSmall
                        : TeaGardenTheme.caption.fontSize,
                    color: colorScheme.onSurface
                        .withOpacity(TeaGardenTheme.opacityHigh),
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

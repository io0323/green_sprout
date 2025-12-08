import 'package:flutter/material.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// 茶葉解析結果カードウィジェット
/// 再利用可能なUIコンポーネント
class TeaAnalysisCard extends StatelessWidget {
  final TeaAnalysisResult result;

  const TeaAnalysisCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: TeaGardenTheme.spacingM,
          vertical: TeaGardenTheme.spacingXS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppUtils.getHealthStatusColor(result.healthStatus),
          child: Icon(
            AppUtils.getHealthStatusIcon(result.healthStatus),
            color: TeaGardenTheme.textLight,
          ),
        ),
        title: Text(result.growthStage),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.healthStatus),
            Text(
              '信頼度: ${AppUtils.formatConfidence(result.confidence)}',
              style: TextStyle(fontSize: TeaGardenTheme.caption.fontSize),
            ),
          ],
        ),
        trailing: Text(
          AppUtils.formatRelativeTime(result.timestamp),
          style: TextStyle(fontSize: TeaGardenTheme.caption.fontSize),
        ),
        onTap: () {
          // 詳細画面への遷移（実装予定）
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../bloc/tea_analysis_cubit.dart';
import '../widgets/tea_analysis_card.dart';

/**
 * 茶葉解析結果カードウィジェット
 * 再利用可能なUIコンポーネント
 */
class TeaAnalysisCard extends StatelessWidget {
  final TeaAnalysisResult result;

  const TeaAnalysisCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppUtils.getHealthStatusColor(result.healthStatus),
          child: Icon(
            AppUtils.getHealthStatusIcon(result.healthStatus),
            color: Colors.white,
          ),
        ),
        title: Text(result.growthStage),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.healthStatus),
            Text(
              '信頼度: ${AppUtils.formatConfidence(result.confidence)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Text(
          AppUtils.formatRelativeTime(result.createdAt),
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          // 詳細画面への遷移（実装予定）
        },
      ),
    );
  }
}

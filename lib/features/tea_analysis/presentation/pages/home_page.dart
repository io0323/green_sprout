import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tea_analysis_cubit.dart';
import '../bloc/analysis_cubit.dart';
import '../widgets/tea_analysis_card.dart';
import '../widgets/camera_button.dart';
import '../widgets/today_summary_card.dart';
import '../../../../core/widgets/modern_ui_components.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// ホームページ
/// クリーンアーキテクチャに基づいたホーム画面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 初期化処理
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeaAnalysisCubit>().loadAllResults();
      context.read<AnalysisCubit>().loadModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '茶園管理AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: colorScheme.onPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/logs');
            },
            tooltip: '日誌一覧',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TeaGardenTheme.backgroundGradient,
        ),
        child: BlocBuilder<TeaAnalysisCubit, TeaAnalysisState>(
          builder: (context, state) {
            if (state is TeaAnalysisLoading) {
              return BeautifulLoadingIndicator(
                message: LocalizationService.instance.translate('data_loading'),
              );
            }

            if (state is TeaAnalysisError) {
              return BeautifulErrorMessage(
                message: state.message,
                onRetry: () {
                  context.read<TeaAnalysisCubit>().loadAllResults();
                },
              );
            }

            if (state is TeaAnalysisLoaded) {
              return Column(
                children: [
                  // 今日のサマリー
                  TodaySummaryCard(results: state.results),

                  // 写真撮影ボタン
                  const CameraButton(),

                  // 最近の解析結果
                  Expanded(
                    child: _buildRecentResults(state.results),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('データが見つかりません'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentResults(List<dynamic> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'まだ解析結果がありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '写真を撮って茶葉を解析してみましょう',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return TeaAnalysisCard(result: result);
      },
    );
  }
}

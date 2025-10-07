import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tea_analysis_cubit.dart';
import '../bloc/analysis_cubit.dart';
import '../bloc/camera_cubit.dart';
import '../widgets/tea_analysis_card.dart';
import '../widgets/camera_button.dart';
import '../widgets/today_summary_card.dart';
import 'camera_page.dart';
import 'log_list_page.dart';

/**
 * ホームページ
 * クリーンアーキテクチャに基づいたホーム画面
 */
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
      context.read<TeaAnalysisCubit>().getAllTeaAnalyses();
      context.read<AnalysisCubit>().loadModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('茶園管理AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/logs');
            },
            tooltip: '日誌一覧',
          ),
        ],
      ),
      body: BlocBuilder<TeaAnalysisCubit, TeaAnalysisState>(
        builder: (context, state) {
          if (state is TeaAnalysisLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TeaAnalysisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TeaAnalysisCubit>().getAllTeaAnalyses();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          if (state is TeaAnalysisLoaded) {
            return Column(
              children: [
                // 今日のサマリー
                TodaySummaryCard(results: state.results),
                
                // 写真撮影ボタン
                const CameraButton(),
                
                // 最近の解析結果一覧
                Expanded(
                  child: _buildRecentResults(state.results),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  /**
   * 最近の解析結果一覧を構築
   */
  Widget _buildRecentResults(List<dynamic> results) {
    final recentResults = results.take(5).toList();

    if (recentResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'まだ解析結果がありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '写真を撮って茶葉を解析してみましょう',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: recentResults.length,
      itemBuilder: (context, index) {
        final result = recentResults[index];
        return TeaAnalysisCard(result: result);
      },
    );
  }
}

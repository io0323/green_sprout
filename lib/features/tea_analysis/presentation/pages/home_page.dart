import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tea_analysis_cubit.dart';
import '../bloc/analysis_cubit.dart';
import '../widgets/tea_analysis_card.dart';
import '../widgets/camera_button.dart';
import '../widgets/today_summary_card.dart';

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
      context.read<TeaAnalysisCubit>().loadAllResults();
      context.read<AnalysisCubit>().loadModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '茶園管理AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/logs');
            },
            tooltip: '日誌一覧',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: BlocBuilder<TeaAnalysisCubit, TeaAnalysisState>(
          builder: (context, state) {
            if (state is TeaAnalysisLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'データを読み込み中...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

          if (state is TeaAnalysisError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'エラーが発生しました',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<TeaAnalysisCubit>().loadAllResults();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('再試行'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
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
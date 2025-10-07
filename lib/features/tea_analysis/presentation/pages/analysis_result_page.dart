import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_utils.dart';
import '../bloc/analysis_cubit.dart';
import '../bloc/tea_analysis_cubit.dart';
import '../widgets/analysis_result_card.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/comment_input_widget.dart';

/**
 * 解析結果ページ
 * クリーンアーキテクチャに基づいた解析結果画面
 */
class AnalysisResultPage extends StatefulWidget {
  final String imagePath;

  const AnalysisResultPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 画像解析を開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisCubit>().analyzeImage(widget.imagePath);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('解析結果'),
        actions: [
          BlocBuilder<AnalysisCubit, AnalysisState>(
            builder: (context, state) {
              if (state is AnalysisCompleted) {
                return TextButton(
                  onPressed: _saveResult,
                  child: const Text(
                    '保存',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 撮影画像
            _buildImagePreview(),
            
            const SizedBox(height: 24),
            
            // 解析結果
            BlocBuilder<AnalysisCubit, AnalysisState>(
              builder: (context, state) {
                if (state is AnalysisAnalyzing) {
                  return _buildAnalyzingIndicator();
                } else if (state is AnalysisCompleted) {
                  return _buildAnalysisResult(state.result);
                } else if (state is AnalysisError) {
                  return _buildErrorState(state.message);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // コメント入力
            BlocBuilder<AnalysisCubit, AnalysisState>(
              builder: (context, state) {
                if (state is AnalysisCompleted) {
                  return CommentInputWidget(
                    controller: _commentController,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 画像プレビューを構築
   */
  Widget _buildImagePreview() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/placeholder.png', // プレースホルダー画像
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /**
   * 解析中インジケーターを構築
   */
  Widget _buildAnalyzingIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '茶葉を解析中...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'AIが成長状態と健康状態を判定しています',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 解析結果を構築
   */
  Widget _buildAnalysisResult(dynamic result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 成長状態
        AnalysisResultCard(
          title: '成長状態',
          value: result.growthStage,
          confidence: result.growthConfidence,
          icon: AppUtils.getGrowthStageIcon(result.growthStage),
          color: Colors.green,
        ),
        
        const SizedBox(height: 16),
        
        // 健康状態
        AnalysisResultCard(
          title: '健康状態',
          value: result.healthStatus,
          confidence: result.healthConfidence,
          icon: AppUtils.getHealthStatusIcon(result.healthStatus),
          color: AppUtils.getHealthStatusColor(result.healthStatus),
        ),
        
        const SizedBox(height: 16),
        
        // 全体信頼度
        ConfidenceIndicator(confidence: result.overallConfidence),
      ],
    );
  }

  /**
   * エラー状態を構築
   */
  Widget _buildErrorState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '解析に失敗しました',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('撮影画面に戻る'),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 結果を保存
   */
  Future<void> _saveResult() async {
    final analysisState = context.read<AnalysisCubit>().state;
    
    if (analysisState is AnalysisCompleted) {
      final result = analysisState.result;
      
      // 茶葉解析結果エンティティを作成
      final teaAnalysis = TeaAnalysisResult(
        imagePath: widget.imagePath,
        growthStage: result.growthStage,
        healthStatus: result.healthStatus,
        confidence: result.overallConfidence,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存実行
      await context.read<TeaAnalysisCubit>().saveTeaAnalysis(teaAnalysis);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('解析結果を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }
}

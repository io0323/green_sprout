import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../bloc/analysis_cubit.dart';
import '../bloc/tea_analysis_cubit.dart';

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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AnalysisCubit, AnalysisState>(
        builder: (context, state) {
          if (state is AnalysisAnalyzing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('茶葉を解析中...'),
                ],
              ),
            );
          } else if (state is AnalysisCompleted) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text('解析完了: ${state.result.growthStage}'),
                  const SizedBox(height: 8),
                  Text('健康状態: ${state.result.healthStatus}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveResult,
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
          } else if (state is AnalysisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('エラー: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('戻る'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: widget.imagePath,
        growthStage: result.growthStage,
        healthStatus: result.healthStatus,
        confidence: result.confidence,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        timestamp: DateTime.now(),
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

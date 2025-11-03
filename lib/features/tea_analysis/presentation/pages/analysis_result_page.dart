import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tea_analysis/presentation/bloc/analysis_cubit.dart';
import '../../../tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../../tea_analysis/presentation/widgets/analysis_result_widget.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../../../../core/widgets/modern_ui_components.dart';
import '../../../../core/services/localization_service.dart';

/// 解析結果ページ
/// 撮影した画像の解析結果を表示
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
  String _comment = '';
  late TeaAnalysisCubit _teaAnalysisCubit;

  @override
  void initState() {
    super.initState();
    _teaAnalysisCubit = sl<TeaAnalysisCubit>();

    // 画像を解析
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisCubit>().analyzeImageFromPath(widget.imagePath);
    });
  }

  @override
  void dispose() {
    _teaAnalysisCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '解析結果',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: BlocBuilder<AnalysisCubit, AnalysisState>(
          builder: (context, state) {
            if (state is AnalysisAnalyzing) {
              return BeautifulLoadingIndicator(
                message:
                    LocalizationService.instance.translate('analyzing_image'),
              );
            }

            if (state is AnalysisError) {
              return BeautifulErrorMessage(
                message: state.message,
                icon: Icons.analytics_outlined,
                onRetry: () {
                  context
                      .read<AnalysisCubit>()
                      .analyzeImageFromPath(widget.imagePath);
                },
              );
            }

            if (state is AnalysisLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 解析結果表示
                    AnalysisResultWidget(
                      result: state.result,
                      imagePath: widget.imagePath,
                    ),

                    const SizedBox(height: 24),

                    // コメント入力
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'コメント',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              hintText: LocalizationService.instance
                                  .translate('comment_hint'),
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                              setState(() {
                                _comment = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 保存ボタン
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedButton(
                        text: LocalizationService.instance
                            .translate('save_result'),
                        icon: Icons.save,
                        onPressed: () {
                          _saveResult(state.result);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Text(
                LocalizationService.instance.translate('unknown_state'),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 解析結果をデータベースに保存する
  void _saveResult(dynamic result) async {
    try {
      // TeaAnalysisResultエンティティを作成
      final teaAnalysisResult = TeaAnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: widget.imagePath,
        growthStage: result.growthStage ?? '不明',
        healthStatus: result.healthStatus ?? '不明',
        confidence: result.confidence ?? 0.0,
        comment: _comment.isNotEmpty ? _comment : null,
        timestamp: DateTime.now(),
      );

      // 保存処理を実行
      await _teaAnalysisCubit.saveTeaAnalysisResult(teaAnalysisResult);

      // 成功メッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.instance.translate('save_result_success'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // ホーム画面に戻る
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      // エラーメッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${LocalizationService.instance.translate('save_result_failed')}: $e',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

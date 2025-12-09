import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tea_analysis/presentation/bloc/analysis_cubit.dart';
import '../../../tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../../tea_analysis/presentation/widgets/analysis_result_widget.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../../../../core/widgets/modern_ui_components.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/tea_garden_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.translate('analysis_title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TeaGardenTheme.backgroundGradient,
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
                child: Column(
                  children: [
                    BeautifulErrorMessage(
                      message: state.message,
                      icon: Icons.analytics_outlined,
                      onRetry: () {
                        context
                            .read<AnalysisCubit>()
                            .analyzeImageFromPath(widget.imagePath);
                      },
                    ),
                    const SizedBox(height: TeaGardenTheme.spacingM),
                    // 高度な分析オプション
                    Card(
                      elevation: TeaGardenTheme.elevationLow,
                      child: Padding(
                        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: TeaGardenTheme.infoColor),
                                const SizedBox(width: TeaGardenTheme.spacingS),
                                Text(
                                  '高度な分析',
                                  style: TextStyle(
                                    fontSize: TeaGardenTheme.bodyLarge.fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: TeaGardenTheme.infoColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TeaGardenTheme.spacingS),
                            Text(
                              '複数の解析手法を組み合わせた高精度な分析を実行します',
                              style: TextStyle(
                                fontSize: TeaGardenTheme.bodySmall.fontSize,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: TeaGardenTheme.spacingM),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final imageFile = File(widget.imagePath);
                                  context
                                      .read<AnalysisCubit>()
                                      .advancedAnalyzeImageFile(imageFile);
                                },
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('高度な分析を実行'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TeaGardenTheme.infoColor,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is AnalysisLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
                child: Column(
                  children: [
                    // 解析結果表示
                    AnalysisResultWidget(
                      result: state.result,
                      imagePath: widget.imagePath,
                    ),

                    const SizedBox(height: TeaGardenTheme.spacingM),

                    // 高度な分析オプション
                    Card(
                      elevation: TeaGardenTheme.elevationLow,
                      child: Padding(
                        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: TeaGardenTheme.infoColor),
                                const SizedBox(width: TeaGardenTheme.spacingS),
                                Text(
                                  '高度な分析',
                                  style: TextStyle(
                                    fontSize: TeaGardenTheme.bodyLarge.fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: TeaGardenTheme.infoColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TeaGardenTheme.spacingS),
                            Text(
                              '複数の解析手法を組み合わせた高精度な分析を実行します',
                              style: TextStyle(
                                fontSize: TeaGardenTheme.bodySmall.fontSize,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: TeaGardenTheme.spacingM),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final imageFile = File(widget.imagePath);
                                  context
                                      .read<AnalysisCubit>()
                                      .advancedAnalyzeImageFile(imageFile);
                                },
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('高度な分析を再実行'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: TeaGardenTheme.infoColor,
                                  side: const BorderSide(
                                    color: TeaGardenTheme.infoColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: TeaGardenTheme.spacingL),

                    // コメント入力
                    Container(
                      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                            TeaGardenTheme.borderRadiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizationService.instance.translate('comment'),
                            style: TextStyle(
                              fontSize: TeaGardenTheme.bodyMedium.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: TeaGardenTheme.spacingS),
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

                    const SizedBox(height: TeaGardenTheme.spacingL),

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
        growthStage: result.growthStage ??
            LocalizationService.instance.translate('unknown'),
        healthStatus: result.healthStatus ??
            LocalizationService.instance.translate('unknown'),
        confidence: result.confidence ?? 0.0,
        comment: _comment.isNotEmpty ? _comment : null,
        timestamp: DateTime.now(),
      );

      // 保存処理を実行
      await _teaAnalysisCubit.saveTeaAnalysisResult(teaAnalysisResult);

      // 成功メッセージを表示
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          LocalizationService.instance.translate('save_result_success'),
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
        SnackBarHelper.showError(
          context,
          '${LocalizationService.instance.translate('save_result_failed')}: $e',
        );
      }
    }
  }
}

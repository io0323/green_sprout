import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_cubit.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/capture_button_widget.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/modern_ui_components.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// カメラページ
/// 茶葉の撮影を行う画面
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // カメラを初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraCubit>().initialize();
    });
  }

  @override
  void dispose() {
    // カメラを破棄
    context.read<CameraCubit>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.translate('camera_title'),
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
        child: BlocBuilder<CameraCubit, CameraBlocState>(
          builder: (context, state) {
            if (state is CameraInitial || state is CameraInitializing) {
              return BeautifulLoadingIndicator(
                message: LocalizationService.instance
                    .translate('camera_initializing'),
              );
            }

            if (state is CameraError) {
              return BeautifulErrorMessage(
                message: state.message,
                icon: Icons.camera_alt_outlined,
                onRetry: () {
                  context.read<CameraCubit>().initialize();
                },
              );
            }

            if (state is CameraInitialized) {
              return Column(
                children: [
                  // 撮影ガイド
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            LocalizationService.instance
                                .translate('place_leaf_center'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // カメラプレビュー
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const CameraPreviewWidget(),
                      ),
                    ),
                  ),

                  // 撮影ボタン
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: const CaptureButtonWidget(),
                  ),
                ],
              );
            }

            if (state is CameraCapturing) {
              return BeautifulLoadingIndicator(
                message: LocalizationService.instance.translate('capturing'),
              );
            }

            if (state is CameraCaptured) {
              // 撮影完了後、解析画面に遷移
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(
                  context,
                  '/analysis',
                  arguments: state.imagePath,
                );
              });

              return BeautifulLoadingIndicator(
                message: LocalizationService.instance
                    .translate('moving_to_analysis'),
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
}

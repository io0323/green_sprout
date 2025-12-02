import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../bloc/camera_cubit.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// カメラプレビューウィジェット
/// カメラの映像を表示
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraCubit, CameraBlocState>(
      builder: (context, state) {
        if (state is CameraInitialized) {
          final cameraController = context.read<CameraCubit>().cameraController;

          if (cameraController != null &&
              cameraController.value.isInitialized) {
            return Stack(
              children: [
                // カメラプレビュー
                SizedBox.expand(
                  child: CameraPreview(cameraController),
                ),

                // 撮影ガイド（中央の枠）
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // 四角の角
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                                left: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                                right: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                                left: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                                right: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width: 3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 上部のオーバーレイ
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          LocalizationService.instance
                              .translate('align_leaf_in_frame'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // 下部のオーバーレイ
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }

        // カメラが初期化されていない場合
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizationService.instance.translate('camera_initializing'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

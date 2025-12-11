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
                    width: TeaGardenTheme.cameraFrameSize,
                    height: TeaGardenTheme.cameraFrameSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        width: TeaGardenTheme.cameraBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(
                          TeaGardenTheme.borderRadiusMedium),
                    ),
                    child: Stack(
                      children: [
                        // 四角の角
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: TeaGardenTheme.cameraCornerSize,
                            height: TeaGardenTheme.cameraCornerSize,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                                left: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: TeaGardenTheme.cameraCornerSize,
                            height: TeaGardenTheme.cameraCornerSize,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                                right: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: TeaGardenTheme.cameraCornerSize,
                            height: TeaGardenTheme.cameraCornerSize,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                                left: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: TeaGardenTheme.cameraCornerSize,
                            height: TeaGardenTheme.cameraCornerSize,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
                                right: BorderSide(
                                    color: TeaGardenTheme.successColor,
                                    width:
                                        TeaGardenTheme.cameraCornerBorderWidth),
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
                    height: TeaGardenTheme.cameraOverlayHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(TeaGardenTheme.opacityLow),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
                        child: Text(
                          LocalizationService.instance
                              .translate('align_leaf_in_frame'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: TeaGardenTheme.bodyMedium.fontSize,
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
                    height: TeaGardenTheme.cameraOverlayHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(TeaGardenTheme.opacityLow),
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
                  size: TeaGardenTheme.iconSizeDefaultLarge,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: TeaGardenTheme.spacingM),
                Text(
                  LocalizationService.instance.translate('camera_initializing'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: TeaGardenTheme.bodyMedium.fontSize,
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

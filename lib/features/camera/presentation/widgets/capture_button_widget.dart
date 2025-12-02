import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_cubit.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// 撮影ボタンウィジェット
/// カメラの撮影ボタン
class CaptureButtonWidget extends StatelessWidget {
  const CaptureButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraCubit, CameraBlocState>(
      builder: (context, state) {
        final isEnabled = state is CameraInitialized;
        final isCapturing = state is CameraCapturing;

        return Column(
          children: [
            // 撮影ボタン
            GestureDetector(
              onTap: isEnabled && !isCapturing
                  ? () => context.read<CameraCubit>().capture()
                  : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEnabled && !isCapturing
                      ? TeaGardenTheme.textLight
                      : Theme.of(context).colorScheme.surfaceVariant,
                  border: Border.all(
                    color: isEnabled && !isCapturing
                        ? TeaGardenTheme.successColor
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isCapturing
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              TeaGardenTheme.successColor,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: isEnabled
                              ? TeaGardenTheme.successColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 撮影説明
            Text(
              isCapturing
                  ? LocalizationService.instance.translate('capturing')
                  : isEnabled
                      ? LocalizationService.instance.translate('take_photo')
                      : LocalizationService.instance
                          .translate('camera_initializing'),
              style: TextStyle(
                fontSize: 16,
                color: isEnabled
                    ? TeaGardenTheme.primaryGreen
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // 撮影のヒント
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: TeaGardenTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TeaGardenTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: TeaGardenTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LocalizationService.instance.translate('capture_tip'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: TeaGardenTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

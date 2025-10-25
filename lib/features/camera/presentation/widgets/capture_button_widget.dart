import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_cubit.dart';

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
                      ? Colors.white
                      : Colors.grey[300],
                  border: Border.all(
                    color: isEnabled && !isCapturing
                        ? Colors.green[400]!
                        : Colors.grey[400]!,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isCapturing
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[400]!,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          size: 40,
                          color:
                              isEnabled ? Colors.green[400] : Colors.grey[400],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 撮影説明
            Text(
              isCapturing
                  ? '撮影中...'
                  : isEnabled
                      ? 'タップして撮影'
                      : 'カメラを初期化中...',
              style: TextStyle(
                fontSize: 16,
                color: isEnabled ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // 撮影のヒント
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '撮影のコツ: 明るい場所で、茶葉全体が映るように撮影してください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
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

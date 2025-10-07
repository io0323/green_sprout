import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_cubit.dart';

/**
 * カメラプレビューウィジェット
 * 再利用可能なUIコンポーネント
 */
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraCubit, CameraBlocState>(
      builder: (context, state) {
        if (state is CameraInitialized) {
          // カメラプレビューを表示（実装は簡略化）
          return const Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey,
                child: Center(
                  child: Text(
                    'カメラプレビュー',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}

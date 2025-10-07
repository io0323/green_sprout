import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_cubit.dart';

/**
 * 撮影ボタンウィジェット
 * 再利用可能なUIコンポーネント
 */
class CaptureButtonWidget extends StatelessWidget {
  const CaptureButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: BlocBuilder<CameraCubit, CameraBlocState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: state is CameraCapturing
                  ? null
                  : () {
                      context.read<CameraCubit>().capture();
                    },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state is CameraCapturing
                      ? Colors.grey
                      : Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: state is CameraCapturing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.black,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

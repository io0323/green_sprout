import 'package:flutter/material.dart';

/**
 * カメラガイドウィジェット
 * 再利用可能なUIコンポーネント
 */
class CameraGuideWidget extends StatelessWidget {
  const CameraGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '茶葉を中央に配置して撮影してください',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// 写真撮影ボタンウィジェット
/// 再利用可能なUIコンポーネント
class CameraButton extends StatelessWidget {
  const CameraButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      child: SizedBox(
        width: double.infinity,
        height: TeaGardenTheme.buttonHeightDefault,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/camera');
          },
          icon: const Icon(Icons.camera_alt,
              size: TeaGardenTheme.iconSizeDefaultMedium),
          label: Text(
            '写真を撮る',
            style: TextStyle(fontSize: TeaGardenTheme.bodyLarge.fontSize),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: TeaGardenTheme.successColor,
            foregroundColor: TeaGardenTheme.textLight,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
            ),
          ),
        ),
      ),
    );
  }
}

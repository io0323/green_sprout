import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';

/// ウェアラブルデバイス用のカメラボタン
/// 大きなタッチターゲットとシンプルなデザイン
class WearableCameraButton extends StatelessWidget {
  final VoidCallback onPressed;

  const WearableCameraButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.instance;
    final isWearable = PlatformUtils.isWearable;

    return SizedBox(
      width: double.infinity,
      height: isWearable ? 80 : 100,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.camera_alt,
          size: isWearable ? 24 : 32,
        ),
        label: Text(
          localization.translate('take_photo'),
          style: TextStyle(
            fontSize: isWearable ? 14 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

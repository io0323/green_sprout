import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/theme/tea_garden_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: isWearable
          ? TeaGardenTheme.buttonHeightWearableLarge
          : TeaGardenTheme.buttonHeightDefaultLarge,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.camera_alt,
          size: isWearable
              ? TeaGardenTheme.iconSizeWearableMedium
              : TeaGardenTheme.iconSizeDefaultMedium,
        ),
        label: Text(
          localization.translate('take_photo'),
          style: TextStyle(
            fontSize: isWearable
                ? TeaGardenTheme.wearableFontSizeMedium
                : TeaGardenTheme.bodyLarge.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
          ),
          elevation: TeaGardenTheme.elevationMedium,
        ),
      ),
    );
  }
}

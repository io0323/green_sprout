import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// カメラガイドウィジェット
/// 再利用可能なUIコンポーネント
class CameraGuideWidget extends StatelessWidget {
  const CameraGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        ),
        child: Text(
          LocalizationService.instance.translate('place_leaf_center'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: TeaGardenTheme.bodyMedium.fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/tea_garden_theme.dart';

/// SnackBar表示を統一するヘルパークラス
/// アプリケーション全体で一貫したSnackBar表示を提供
class SnackBarHelper {
  SnackBarHelper._();

  /// 成功メッセージを表示
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  /// エラーメッセージを表示
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  /// 警告メッセージを表示
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TeaGardenTheme.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  /// 情報メッセージを表示
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TeaGardenTheme.infoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  /// カスタムSnackBarを表示
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.surface,
        duration: duration ?? AnimationConstants.fourSeconds,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        ),
        action: action,
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../theme/tea_garden_theme.dart';

/**
 * アクセシビリティ機能の強化ユーティリティ
 * 視覚障害、聴覚障害、運動障害に対応
 */
class AccessibilityHelper {
  /**
   * セマンティクスラベルを生成
   */
  static String generateSemanticsLabel({
    required String baseLabel,
    String? additionalInfo,
    String? status,
    String? action,
  }) {
    String label = baseLabel;

    if (additionalInfo != null) {
      label += '、$additionalInfo';
    }

    if (status != null) {
      label += '、状態: $status';
    }

    if (action != null) {
      label += '、$action';
    }

    return label;
  }

  /**
   * 色のコントラスト比を計算
   */
  static double calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = _calculateLuminance(color1);
    final luminance2 = _calculateLuminance(color2);

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /**
   * 色の輝度を計算
   */
  static double _calculateLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /**
   * 色成分を線形化
   */
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return pow((component + 0.055) / 1.055, 2.4);
    }
  }

  /**
   * アクセシブルな色を取得
   */
  static Color getAccessibleColor(
    Color backgroundColor, {
    Color? lightColor,
    Color? darkColor,
  }) {
    final light = lightColor ?? Colors.white;
    final dark = darkColor ?? Colors.black;

    final lightContrast = calculateContrastRatio(backgroundColor, light);
    final darkContrast = calculateContrastRatio(backgroundColor, dark);

    return lightContrast > darkContrast ? light : dark;
  }

  /**
   * フォントサイズをスケール
   */
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;

    // 最小・最大スケールファクターを制限
    final clampedScaleFactor = textScaleFactor.clamp(0.8, 2.0);

    return baseFontSize * clampedScaleFactor;
  }

  /**
   * タッチターゲットサイズを確認
   */
  static bool isTouchTargetAccessible(Size size) {
    const minSize = 44.0; // iOS/Android の最小タッチターゲットサイズ
    return size.width >= minSize && size.height >= minSize;
  }

  /**
   * フォーカス可能な要素の順序を管理
   */
  static List<FocusNode> createFocusOrder(List<Widget> widgets) {
    return List.generate(widgets.length, (index) => FocusNode());
  }
}

/**
 * アクセシブルなカードウィジェット
 */
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final String? semanticsHint;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.semanticsHint,
    this.onTap,
    this.isSelected = false,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: onTap != null,
      selected: isSelected,
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.all(TeaGardenTheme.spacingM),
        padding: padding ?? const EdgeInsets.all(TeaGardenTheme.spacingL),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
          border: isSelected
              ? Border.all(color: TeaGardenTheme.primaryGreen, width: 2)
              : null,
          boxShadow: TeaGardenTheme.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

/**
 * アクセシブルなボタン
 */
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticsLabel;
  final String? semanticsHint;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const AccessibleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.semanticsLabel,
    this.semanticsHint,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final effectiveSemanticsLabel = semanticsLabel ??
        AccessibilityHelper.generateSemanticsLabel(
          baseLabel: text,
          status: isLoading ? '読み込み中' : null,
          action: isEnabled ? 'タップして実行' : '無効',
        );

    return Semantics(
      label: effectiveSemanticsLabel,
      hint: semanticsHint,
      button: true,
      enabled: isEnabled,
      onTap: isEnabled ? onPressed : null,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TeaGardenTheme.spacingL,
          vertical: TeaGardenTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? (backgroundColor ?? TeaGardenTheme.primaryGreen)
              : TeaGardenTheme.textSecondary,
          borderRadius:
              BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
          boxShadow: TeaGardenTheme.buttonShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: TeaGardenTheme.spacingS),
            ] else if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? Colors.white,
                size: 20,
              ),
              const SizedBox(width: TeaGardenTheme.spacingS),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: AccessibilityHelper.getScaledFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * アクセシブルな画像
 */
class AccessibleImage extends StatelessWidget {
  final String imagePath;
  final String semanticsLabel;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;

  const AccessibleImage({
    super.key,
    required this.imagePath,
    required this.semanticsLabel,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: TeaGardenTheme.textSecondary.withOpacity(0.1),
                child: const Icon(
                  Icons.image_not_supported,
                  color: TeaGardenTheme.textSecondary,
                ),
              );
        },
      ),
    );
  }
}

/**
 * アクセシブルなテキストフィールド
 */
class AccessibleTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? semanticsLabel;
  final String? semanticsHint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;

  const AccessibleTextField({
    super.key,
    required this.label,
    this.hint,
    this.semanticsLabel,
    this.semanticsHint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? label,
      hint: semanticsHint ?? hint,
      textField: true,
      enabled: enabled,
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        enabled: enabled,
        style: TextStyle(
          fontSize: AccessibilityHelper.getScaledFontSize(context, 16),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
            borderSide:
                const BorderSide(color: TeaGardenTheme.primaryGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: TeaGardenTheme.spacingM,
            vertical: TeaGardenTheme.spacingM,
          ),
        ),
      ),
    );
  }
}

/**
 * アクセシブルなプログレスインジケーター
 */
class AccessibleProgressIndicator extends StatelessWidget {
  final double value;
  final String? semanticsLabel;
  final Color? backgroundColor;
  final Color? valueColor;

  const AccessibleProgressIndicator({
    super.key,
    required this.value,
    this.semanticsLabel,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();
    final effectiveSemanticsLabel = semanticsLabel ?? '進捗: $percentage%';

    return Semantics(
      label: effectiveSemanticsLabel,
      value: '$percentage%',
      child: LinearProgressIndicator(
        value: value,
        backgroundColor:
            backgroundColor ?? TeaGardenTheme.textSecondary.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? TeaGardenTheme.primaryGreen,
        ),
      ),
    );
  }
}

/**
 * アクセシビリティ設定ダイアログ
 */
class AccessibilitySettingsDialog extends StatefulWidget {
  const AccessibilitySettingsDialog({super.key});

  @override
  State<AccessibilitySettingsDialog> createState() =>
      _AccessibilitySettingsDialogState();
}

class _AccessibilitySettingsDialogState
    extends State<AccessibilitySettingsDialog> {
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  bool _screenReader = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('アクセシビリティ設定'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('高コントラスト'),
              subtitle: const Text('色のコントラストを高くします'),
              value: _highContrast,
              onChanged: (value) {
                setState(() {
                  _highContrast = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('大きなテキスト'),
              subtitle: const Text('テキストサイズを大きくします'),
              value: _largeText,
              onChanged: (value) {
                setState(() {
                  _largeText = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('アニメーションを減らす'),
              subtitle: const Text('動きを少なくします'),
              value: _reduceMotion,
              onChanged: (value) {
                setState(() {
                  _reduceMotion = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('スクリーンリーダー対応'),
              subtitle: const Text('音声読み上げを最適化します'),
              value: _screenReader,
              onChanged: (value) {
                setState(() {
                  _screenReader = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            // 設定を保存
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/tea_garden_theme.dart';

/// モダンなカードウィジェット
/// 美しいシャドウとアニメーション付き
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enableAnimation;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.enableAnimation = true,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.shortDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin ?? const EdgeInsets.all(TeaGardenTheme.spacingM),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
        boxShadow: TeaGardenTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.enableAnimation
              ? (_) => _animationController.forward()
              : null,
          onTapUp: widget.enableAnimation
              ? (_) => _animationController.reverse()
              : null,
          onTapCancel: widget.enableAnimation
              ? () => _animationController.reverse()
              : null,
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
          child: Padding(
            padding:
                widget.padding ?? const EdgeInsets.all(TeaGardenTheme.spacingL),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.enableAnimation) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: card,
          );
        },
      );
    }

    return card;
  }
}

/// アニメーション付きボタン
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool isEnabled;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.mediumDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.defaultCurve,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled && !widget.isLoading
          ? (_) => _animationController.forward()
          : null,
      onTapUp: widget.isEnabled && !widget.isLoading
          ? (_) => _animationController.reverse()
          : null,
      onTapCancel: widget.isEnabled && !widget.isLoading
          ? () => _animationController.reverse()
          : null,
      onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TeaGardenTheme.spacingL,
                vertical: TeaGardenTheme.spacingM,
              ),
              decoration: BoxDecoration(
                color: widget.isEnabled
                    ? (widget.backgroundColor ?? TeaGardenTheme.primaryGreen)
                    : TeaGardenTheme.textSecondary,
                borderRadius:
                    BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
                boxShadow: TeaGardenTheme.buttonShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading) ...[
                    Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: TeaGardenTheme.spacingS),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor ?? Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: TeaGardenTheme.spacingS),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 美しいローディングインジケーター
class BeautifulLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;

  const BeautifulLoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  State<BeautifulLoadingIndicator> createState() =>
      _BeautifulLoadingIndicatorState();
}

class _BeautifulLoadingIndicatorState extends State<BeautifulLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: TeaGardenTheme.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: TeaGardenTheme.spacingL),
            Text(
              widget.message!,
              style: TeaGardenTheme.bodyMedium.copyWith(
                color: TeaGardenTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 美しいエラーメッセージウィジェット
class BeautifulErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const BeautifulErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(TeaGardenTheme.spacingL),
              decoration: BoxDecoration(
                color: TeaGardenTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: TeaGardenTheme.errorColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: TeaGardenTheme.errorColor,
              ),
            ),
            const SizedBox(height: TeaGardenTheme.spacingL),
            Text(
              'エラーが発生しました',
              style: TeaGardenTheme.heading3.copyWith(
                color: TeaGardenTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TeaGardenTheme.spacingS),
            Text(
              message,
              style: TeaGardenTheme.bodyMedium.copyWith(
                color: TeaGardenTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: TeaGardenTheme.spacingL),
              AnimatedButton(
                text: '再試行',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 美しい成功メッセージウィジェット
class BeautifulSuccessMessage extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;

  const BeautifulSuccessMessage({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  State<BeautifulSuccessMessage> createState() =>
      _BeautifulSuccessMessageState();
}

class _BeautifulSuccessMessageState extends State<BeautifulSuccessMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.mediumDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.bounceCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(TeaGardenTheme.spacingL),
              decoration: BoxDecoration(
                color: TeaGardenTheme.successColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
                border: Border.all(
                  color: TeaGardenTheme.successColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: TeaGardenTheme.successColor,
                    size: 32,
                  ),
                  const SizedBox(width: TeaGardenTheme.spacingM),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TeaGardenTheme.bodyLarge.copyWith(
                        color: TeaGardenTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.onDismiss != null)
                    IconButton(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.close),
                      color: TeaGardenTheme.successColor,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

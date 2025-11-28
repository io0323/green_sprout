import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// ウェアラブルデバイス用のエラー表示ウィジェット
/// コンパクトなUIでエラーメッセージを表示し、リトライ機能を提供
class WearableErrorWidget extends StatelessWidget {
  /// エラーメッセージ
  final String message;

  /// エラーの種類（オプション）
  final Failure? failure;

  /// リトライコールバック
  final VoidCallback? onRetry;

  /// カスタムアイコン
  final IconData? icon;

  const WearableErrorWidget({
    super.key,
    required this.message,
    this.failure,
    this.onRetry,
    this.icon,
  });

  /// エラーの種類に応じたアイコンを取得
  IconData _getErrorIcon() {
    if (icon != null) return icon!;

    if (failure != null) {
      if (failure is NetworkFailure) {
        return Icons.wifi_off;
      } else if (failure is CacheFailure) {
        return Icons.storage;
      } else if (failure is CameraFailure) {
        return Icons.camera_alt;
      } else if (failure is TFLiteFailure) {
        return Icons.smart_toy;
      } else if (failure is ServerFailure) {
        return Icons.cloud_off;
      } else if (failure is WearableFailure) {
        return Icons.watch;
      }
    }

    return Icons.error_outline;
  }

  /// エラーの種類に応じた色を取得
  /// テーマのエラー色をベースに、エラーの種類に応じた色を返す
  Color _getErrorColor(BuildContext context) {
    final theme = Theme.of(context);
    final baseErrorColor = theme.colorScheme.error;

    if (failure != null) {
      if (failure is NetworkFailure) {
        return TeaGardenTheme.warningColor;
      } else if (failure is CacheFailure) {
        return TeaGardenTheme.infoColor;
      } else if (failure is CameraFailure) {
        return Colors.purple;
      } else if (failure is TFLiteFailure) {
        return baseErrorColor;
      } else if (failure is ServerFailure) {
        return TeaGardenTheme.warningColor;
      } else if (failure is WearableFailure) {
        return Colors.teal;
      }
    }

    return baseErrorColor;
  }

  /// エラーの種類に応じた詳細メッセージを取得
  String _getDetailedMessage() {
    final localization = LocalizationService.instance;
    final baseMessage = message;

    if (failure != null) {
      String errorType = '';
      String suggestion = '';

      if (failure is NetworkFailure) {
        errorType = localization.translate('error_network');
        suggestion = localization.translate('error_network_suggestion');
      } else if (failure is CacheFailure) {
        errorType = localization.translate('error_cache');
        suggestion = localization.translate('error_cache_suggestion');
      } else if (failure is CameraFailure) {
        errorType = localization.translate('error_camera');
        suggestion = localization.translate('error_camera_suggestion');
      } else if (failure is TFLiteFailure) {
        errorType = localization.translate('error_ai');
        suggestion = localization.translate('error_ai_suggestion');
      } else if (failure is ServerFailure) {
        errorType = localization.translate('error_server');
        suggestion = localization.translate('error_server_suggestion');
      } else if (failure is WearableFailure) {
        errorType = localization.translate('error_wearable');
        suggestion = localization.translate('error_wearable_suggestion');
      } else {
        errorType = localization.translate('error_unknown');
        suggestion = localization.translate('error_unknown_suggestion');
      }

      return '$baseMessage\n\n$errorType\n$suggestion';
    }

    return baseMessage;
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.instance;
    final isWearable = PlatformUtils.isWearable;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final errorColor = _getErrorColor(context);
    final errorIcon = _getErrorIcon();
    final detailedMessage = _getDetailedMessage();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isWearable ? 12.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // エラーアイコン
            Container(
              padding: EdgeInsets.all(isWearable ? 12.0 : 16.0),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: errorColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                errorIcon,
                size: isWearable ? 32 : 40,
                color: errorColor,
              ),
            ),

            SizedBox(height: isWearable ? 12 : 16),

            // エラータイトル
            Text(
              localization.translate('error_occurred'),
              style: TextStyle(
                fontSize: isWearable ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: errorColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isWearable ? 8 : 12),

            // エラーメッセージ
            Text(
              detailedMessage,
              style: TextStyle(
                fontSize: isWearable ? 10 : 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: isWearable ? 4 : 6,
              overflow: TextOverflow.ellipsis,
            ),

            // リトライボタン
            if (onRetry != null) ...[
              SizedBox(height: isWearable ? 12 : 16),
              SizedBox(
                width: double.infinity,
                height: isWearable ? 40 : 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(
                    Icons.refresh,
                    size: isWearable ? 16 : 20,
                  ),
                  label: Text(
                    localization.translate('retry'),
                    style: TextStyle(
                      fontSize: isWearable ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

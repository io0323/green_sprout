import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/utils/failure_message_mapper.dart';
import '../../../../core/errors/failures.dart';

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
      return FailureMessageMapper.getErrorIcon(failure!);
    }

    return Icons.error_outline;
  }

  /// エラーの種類に応じた色を取得
  /// テーマのエラー色をベースに、エラーの種類に応じた色を返す
  Color _getErrorColor(BuildContext context) {
    final theme = Theme.of(context);
    final baseErrorColor = theme.colorScheme.error;

    if (failure != null) {
      return FailureMessageMapper.getErrorColor(
        failure!,
        baseErrorColor: baseErrorColor,
      );
    }

    return baseErrorColor;
  }

  /// エラーの種類に応じた詳細メッセージを取得
  String _getDetailedMessage() {
    final baseMessage = message;

    if (failure != null) {
      final errorInfo =
          FailureMessageMapper.getErrorTypeAndSuggestion(failure!);
      return '$baseMessage\n\n${errorInfo.errorType}\n${errorInfo.suggestion}';
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

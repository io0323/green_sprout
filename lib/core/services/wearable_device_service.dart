import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../errors/failures.dart';
import '../../features/tea_analysis/domain/entities/tea_analysis_result.dart';
import '../theme/tea_garden_theme.dart';

/// ウェアラブルデバイスサービスのインターフェース
abstract class WearableDeviceService {
  Future<bool> isConnected();
  Future<void> connect();
  Future<void> disconnect();
  Future<void> sendAnalysisResult(TeaAnalysisResult result);
  Future<void> sendNotification(String title, String message);
  Stream<WearableEvent> get eventStream;
}

/// ウェアラブルデバイスサービスの実装
/// Wear OS (Android) と watchOS (iOS) に対応
class WearableDeviceServiceImpl implements WearableDeviceService {
  static const MethodChannel _channel = MethodChannel('tea_garden_wearable');

  final StreamController<WearableEvent> _eventController =
      StreamController<WearableEvent>.broadcast();

  bool _isConnected = false;
  Timer? _heartbeatTimer;

  WearableDeviceServiceImpl() {
    _initializeChannel();
  }

  void _initializeChannel() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onWearableConnected':
        _isConnected = true;
        _eventController.add(WearableEvent.connected());
        break;
      case 'onWearableDisconnected':
        _isConnected = false;
        _eventController.add(WearableEvent.disconnected());
        break;
      case 'onWearableDataReceived':
        final data = call.arguments as Map<String, dynamic>;
        _eventController.add(WearableEvent.dataReceived(data));
        break;
      case 'onWearableError':
        final error = call.arguments as String;
        _eventController.add(WearableEvent.error(error));
        break;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod('isWearableConnected');
      _isConnected = result as bool;
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> connect() async {
    try {
      await _channel.invokeMethod('connectWearable');
      _isConnected = true;
      _startHeartbeat();
    } catch (e) {
      _isConnected = false;
      throw WearableFailure('ウェアラブルデバイスの接続に失敗しました: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnectWearable');
      _stopHeartbeat();
      _isConnected = false;
    } catch (e) {
      throw WearableFailure('ウェアラブルデバイスの切断に失敗しました: $e');
    }
  }

  @override
  Future<void> sendAnalysisResult(TeaAnalysisResult result) async {
    if (!_isConnected) {
      throw const WearableFailure('ウェアラブルデバイスが接続されていません');
    }

    try {
      final data = {
        'type': 'analysis_result',
        'id': result.id,
        'growthStage': result.growthStage,
        'healthStatus': result.healthStatus,
        'confidence': result.confidence,
        'timestamp': result.timestamp.toIso8601String(),
        'comment': result.comment ?? '',
      };

      await _channel.invokeMethod('sendToWearable', {'data': data});
    } catch (e) {
      throw WearableFailure('データの送信に失敗しました: $e');
    }
  }

  @override
  Future<void> sendNotification(String title, String message) async {
    if (!_isConnected) {
      throw const WearableFailure('ウェアラブルデバイスが接続されていません');
    }

    try {
      final data = {
        'type': 'notification',
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _channel.invokeMethod('sendToWearable', {'data': data});
    } catch (e) {
      throw WearableFailure('通知の送信に失敗しました: $e');
    }
  }

  @override
  Stream<WearableEvent> get eventStream => _eventController.stream;

  /// ハートビートを開始
  void _startHeartbeat() {
    // 既存のタイマーがある場合は停止
    _stopHeartbeat();
    _heartbeatTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isConnected) {
        try {
          await _channel.invokeMethod('sendHeartbeat');
        } catch (e) {
          _isConnected = false;
          _eventController.add(WearableEvent.disconnected());
          _stopHeartbeat();
        }
      } else {
        // 接続が切れている場合はタイマーを停止
        _stopHeartbeat();
      }
    });
  }

  /// ハートビートを停止
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void dispose() {
    _stopHeartbeat();
    _eventController.close();
  }
}

/// ウェアラブルイベント
class WearableEvent {
  final WearableEventType type;
  final Map<String, dynamic>? data;
  final String? error;

  WearableEvent._(this.type, {this.data, this.error});

  factory WearableEvent.connected() =>
      WearableEvent._(WearableEventType.connected);
  factory WearableEvent.disconnected() =>
      WearableEvent._(WearableEventType.disconnected);
  factory WearableEvent.dataReceived(Map<String, dynamic> data) =>
      WearableEvent._(WearableEventType.dataReceived, data: data);
  factory WearableEvent.error(String error) =>
      WearableEvent._(WearableEventType.error, error: error);
}

enum WearableEventType {
  connected,
  disconnected,
  dataReceived,
  error,
}

/// ウェアラブル専用のUIコンポーネント
class WearableAnalysisCard extends StatelessWidget {
  final TeaAnalysisResult result;
  final VoidCallback? onTap;

  const WearableAnalysisCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(TeaGardenTheme.spacingXS),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(TeaGardenTheme.spacingS),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成長状態
              Row(
                children: [
                  const Icon(Icons.eco,
                      size: TeaGardenTheme.iconSizeWearableSmall),
                  const SizedBox(width: TeaGardenTheme.spacingXS),
                  Expanded(
                    child: Text(
                      result.growthStage,
                      style: TextStyle(
                          fontSize: TeaGardenTheme.caption.fontSize,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TeaGardenTheme.spacingXS),
              // 健康状態
              Row(
                children: [
                  Icon(
                    _getHealthIcon(result.healthStatus),
                    size: TeaGardenTheme.wearableFontSizeMedium,
                    color: _getHealthColor(result.healthStatus),
                  ),
                  const SizedBox(width: TeaGardenTheme.spacingXS),
                  Expanded(
                    child: Text(
                      result.healthStatus,
                      style: TextStyle(
                        fontSize: TeaGardenTheme.wearableFontSizeSmall,
                        color: _getHealthColor(result.healthStatus),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TeaGardenTheme.spacingXS),
              // 信頼度
              LinearProgressIndicator(
                value: result.confidence,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(context, result.confidence),
                ),
              ),
              const SizedBox(height: TeaGardenTheme.spacingXS),
              Text(
                '${(result.confidence * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: TeaGardenTheme.wearableFontSizeSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getHealthIcon(String healthStatus) {
    switch (healthStatus) {
      case '健康':
        return Icons.favorite;
      case '軽微な損傷':
        return Icons.warning;
      case '損傷':
        return Icons.error;
      case '病気':
        return Icons.sick;
      default:
        return Icons.help;
    }
  }

  Color _getHealthColor(String healthStatus) {
    switch (healthStatus) {
      case '健康':
        return TeaGardenTheme.successColor;
      case '軽微な損傷':
        return TeaGardenTheme.warningColor;
      case '損傷':
        return TeaGardenTheme.errorColor;
      case '病気':
        return TeaGardenTheme.errorColor;
      default:
        return TeaGardenTheme.infoColor;
    }
  }

  Color _getConfidenceColor(BuildContext context, double confidence) {
    final theme = Theme.of(context);
    if (confidence >= 0.8) return TeaGardenTheme.successColor;
    if (confidence >= 0.6) return TeaGardenTheme.warningColor;
    return theme.colorScheme.error;
  }
}

/// ウェアラブル用の簡易カメラコントロール
class WearableCameraControl extends StatelessWidget {
  final VoidCallback? onCapture;
  final bool isCapturing;

  const WearableCameraControl({
    super.key,
    this.onCapture,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final buttonColor = isCapturing ? colorScheme.error : colorScheme.primary;
    final iconColor = colorScheme.onPrimary;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: buttonColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCapturing ? null : onCapture,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Icon(
              Icons.camera_alt,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

/// ウェアラブル専用の通知ウィジェット
class WearableNotification extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const WearableNotification({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurface.withOpacity(0.7);

    return Container(
      margin: const EdgeInsets.all(TeaGardenTheme.spacingXS),
      padding: const EdgeInsets.all(TeaGardenTheme.spacingS),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications,
                color: colorScheme.primary,
                size: TeaGardenTheme.iconSizeWearableSmall,
              ),
              const SizedBox(width: TeaGardenTheme.spacingXS),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: TeaGardenTheme.caption.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    color: textColor,
                    size: TeaGardenTheme.wearableFontSizeMedium,
                  ),
                ),
            ],
          ),
          const SizedBox(height: TeaGardenTheme.spacingXS),
          Text(
            message,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: TeaGardenTheme.wearableFontSizeSmall,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

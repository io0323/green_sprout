import '../errors/failures.dart';
import '../services/localization_service.dart';

/// Failureオブジェクトをユーザーフレンドリーなメッセージに変換するユーティリティクラス
class FailureMessageMapper {
  FailureMessageMapper._();

  /// Failureオブジェクトをユーザーフレンドリーなメッセージに変換
  /// [failure] 変換するFailureオブジェクト
  /// [useLocalization] 国際化サービスを使用するかどうか（デフォルト: true）
  /// 国際化サービスが使用できない場合はハードコードされた日本語メッセージを返す
  static String mapToMessage(Failure failure, {bool useLocalization = true}) {
    if (useLocalization) {
      try {
        final localization = LocalizationService.instance;
        if (failure is ServerFailure) {
          return localization.translate('error_server_detail',
              params: {'message': failure.message});
        } else if (failure is CacheFailure) {
          return localization.translate('error_cache_detail',
              params: {'message': failure.message});
        } else if (failure is NetworkFailure) {
          return localization.translate('error_network_detail',
              params: {'message': failure.message});
        } else if (failure is CameraFailure) {
          return localization.translate('error_camera_detail',
              params: {'message': failure.message});
        } else if (failure is TFLiteFailure) {
          return localization.translate('error_ai_detail',
              params: {'message': failure.message});
        } else if (failure is WearableFailure) {
          return localization.translate('error_wearable_detail',
              params: {'message': failure.message});
        } else {
          return localization.translate('error_unknown_detail',
              params: {'message': failure.message});
        }
      } catch (e) {
        // 国際化サービスが使用できない場合はフォールバック
        return _mapToHardcodedMessage(failure);
      }
    } else {
      return _mapToHardcodedMessage(failure);
    }
  }

  /// Failureオブジェクトをハードコードされた日本語メッセージに変換
  /// [failure] 変換するFailureオブジェクト
  static String _mapToHardcodedMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'サーバーエラーが発生しました: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'データエラーが発生しました: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'ネットワークエラーが発生しました: ${failure.message}';
    } else if (failure is CameraFailure) {
      return 'カメラエラーが発生しました: ${failure.message}';
    } else if (failure is TFLiteFailure) {
      return 'AI解析エラーが発生しました: ${failure.message}';
    } else if (failure is WearableFailure) {
      return 'ウェアラブルデバイスエラーが発生しました: ${failure.message}';
    } else {
      return '不明なエラーが発生しました: ${failure.message}';
    }
  }

  /// Failureオブジェクトのエラータイプと提案を取得
  /// [failure] 変換するFailureオブジェクト
  /// 戻り値: (errorType, suggestion) のタプル
  static ({String errorType, String suggestion}) getErrorTypeAndSuggestion(
    Failure failure,
  ) {
    try {
      final localization = LocalizationService.instance;
      if (failure is NetworkFailure) {
        return (
          errorType: localization.translate('error_network'),
          suggestion: localization.translate('error_network_suggestion'),
        );
      } else if (failure is CacheFailure) {
        return (
          errorType: localization.translate('error_cache'),
          suggestion: localization.translate('error_cache_suggestion'),
        );
      } else if (failure is CameraFailure) {
        return (
          errorType: localization.translate('error_camera'),
          suggestion: localization.translate('error_camera_suggestion'),
        );
      } else if (failure is TFLiteFailure) {
        return (
          errorType: localization.translate('error_ai'),
          suggestion: localization.translate('error_ai_suggestion'),
        );
      } else if (failure is ServerFailure) {
        return (
          errorType: localization.translate('error_server'),
          suggestion: localization.translate('error_server_suggestion'),
        );
      } else if (failure is WearableFailure) {
        return (
          errorType: localization.translate('error_wearable'),
          suggestion: localization.translate('error_wearable_suggestion'),
        );
      } else {
        return (
          errorType: localization.translate('error_unknown'),
          suggestion: localization.translate('error_unknown_suggestion'),
        );
      }
    } catch (e) {
      // 国際化サービスが使用できない場合はデフォルト値を返す
      return (
        errorType: 'エラー',
        suggestion: 'もう一度お試しください',
      );
    }
  }
}

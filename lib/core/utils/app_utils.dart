import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// ユーティリティクラス
/// アプリケーション全体で使用する共通機能
class AppUtils {
  /// 日時をフォーマット（相対時間）
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  /// 日時をフォーマット（絶対時間）
  static String formatAbsoluteTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 信頼度に応じた色を取得
  static Color getConfidenceColor(double confidence) {
    if (confidence >= AppConstants.highConfidenceThreshold) {
      return Colors.green;
    } else if (confidence >= AppConstants.mediumConfidenceThreshold) {
      return Colors.yellow;
    } else if (confidence >= AppConstants.lowConfidenceThreshold) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 健康状態に応じた色を取得
  static Color getHealthStatusColor(String status) {
    switch (status) {
      case HealthStatusConstants.healthy:
        return Colors.green;
      case HealthStatusConstants.slightlyDamaged:
        return Colors.yellow;
      case HealthStatusConstants.damaged:
        return Colors.orange;
      case HealthStatusConstants.diseased:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 健康状態に応じたアイコンを取得
  static IconData getHealthStatusIcon(String status) {
    switch (status) {
      case HealthStatusConstants.healthy:
        return Icons.check_circle;
      case HealthStatusConstants.slightlyDamaged:
        return Icons.warning;
      case HealthStatusConstants.damaged:
        return Icons.error;
      case HealthStatusConstants.diseased:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  /// 成長状態に応じたアイコンを取得
  static IconData getGrowthStageIcon(String stage) {
    switch (stage) {
      case GrowthStageConstants.bud:
        return Icons.eco;
      case GrowthStageConstants.youngLeaf:
        return Icons.local_florist;
      case GrowthStageConstants.matureLeaf:
        return Icons.park;
      case GrowthStageConstants.oldLeaf:
        return Icons.nature;
      default:
        return Icons.help;
    }
  }

  /// 信頼度をパーセンテージ文字列に変換
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  /// ファイルサイズを人間が読みやすい形式に変換
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 文字列が空かnullかチェック
  static bool isEmptyOrNull(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// 文字列を安全にトリム
  static String? safeTrim(String? value) {
    return value?.trim().isEmpty == true ? null : value?.trim();
  }
}

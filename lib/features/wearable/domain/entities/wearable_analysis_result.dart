/**
 * ウェアラブルデバイス用の解析結果エンティティ
 * 簡潔な情報のみを含む
 */
class WearableAnalysisResult {
  /// 成長段階
  final String growthStage;

  /// 健康状態
  final String healthStatus;

  /// 信頼度（0.0-1.0）
  final double confidence;

  /// タイムスタンプ
  final DateTime timestamp;

  /**
   * コンストラクタ
   */
  const WearableAnalysisResult({
    required this.growthStage,
    required this.healthStatus,
    required this.confidence,
    required this.timestamp,
  });

  /**
   * JSONから作成
   */
  factory WearableAnalysisResult.fromJson(Map<String, dynamic> json) {
    return WearableAnalysisResult(
      growthStage: json['growthStage'] as String,
      healthStatus: json['healthStatus'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /**
   * JSONに変換
   */
  Map<String, dynamic> toJson() {
    return {
      'growthStage': growthStage,
      'healthStatus': healthStatus,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

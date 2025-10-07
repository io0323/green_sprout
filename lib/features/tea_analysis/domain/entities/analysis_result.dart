/**
 * 解析結果のドメインエンティティ
 * AI解析の結果を表現する
 */
class AnalysisResult {
  final String growthStage;
  final double growthConfidence;
  final String healthStatus;
  final double healthConfidence;
  final double overallConfidence;

  const AnalysisResult({
    required this.growthStage,
    required this.growthConfidence,
    required this.healthStatus,
    required this.healthConfidence,
    required this.overallConfidence,
  });

  /**
   * エンティティの等価性を比較
   */
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisResult &&
        other.growthStage == growthStage &&
        other.growthConfidence == growthConfidence &&
        other.healthStatus == healthStatus &&
        other.healthConfidence == healthConfidence &&
        other.overallConfidence == overallConfidence;
  }

  /**
   * ハッシュコードを生成
   */
  @override
  int get hashCode {
    return Object.hash(
      growthStage,
      growthConfidence,
      healthStatus,
      healthConfidence,
      overallConfidence,
    );
  }

  /**
   * 文字列表現
   */
  @override
  String toString() {
    return 'AnalysisResult(growthStage: $growthStage, growthConfidence: $growthConfidence, healthStatus: $healthStatus, healthConfidence: $healthConfidence, overallConfidence: $overallConfidence)';
  }

  /**
   * 信頼度が高いかどうかを判定
   */
  bool get isHighConfidence {
    return overallConfidence >= 0.8;
  }

  /**
   * 健康状態が良好かどうかを判定
   */
  bool get isHealthy {
    return healthStatus == '健康';
  }
}

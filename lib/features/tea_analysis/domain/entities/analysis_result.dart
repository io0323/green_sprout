/// 解析結果のドメインエンティティ
/// AI解析の結果を表現する
class AnalysisResult {
  final String growthStage;
  final String healthStatus;
  final double confidence;

  const AnalysisResult({
    required this.growthStage,
    required this.healthStatus,
    required this.confidence,
  });

  /// エンティティの等価性を比較
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisResult &&
        other.growthStage == growthStage &&
        other.healthStatus == healthStatus &&
        other.confidence == confidence;
  }

  /// ハッシュコードを生成
  @override
  int get hashCode {
    return Object.hash(
      growthStage,
      healthStatus,
      confidence,
    );
  }

  /// 文字列表現
  @override
  String toString() {
    return 'AnalysisResult(growthStage: $growthStage, healthStatus: $healthStatus, confidence: $confidence)';
  }

  /// 信頼度が高いかどうかを判定
  bool get isHighConfidence {
    return confidence >= 0.8;
  }

  /// 健康状態が良好かどうかを判定
  bool get isHealthy {
    return healthStatus == '健康';
  }
}

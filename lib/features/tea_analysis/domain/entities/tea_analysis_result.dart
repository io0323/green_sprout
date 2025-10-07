/**
 * 茶葉解析結果のドメインエンティティ
 * ビジネスロジックの中核となるオブジェクト
 */
class TeaAnalysisResult {
  final int? id;
  final String imagePath;
  final String growthStage;
  final String healthStatus;
  final double confidence;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeaAnalysisResult({
    this.id,
    required this.imagePath,
    required this.growthStage,
    required this.healthStatus,
    required this.confidence,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  /**
   * コメントを更新した新しいインスタンスを作成
   */
  TeaAnalysisResult copyWith({
    int? id,
    String? imagePath,
    String? growthStage,
    String? healthStatus,
    double? confidence,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeaAnalysisResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      growthStage: growthStage ?? this.growthStage,
      healthStatus: healthStatus ?? this.healthStatus,
      confidence: confidence ?? this.confidence,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /**
   * エンティティの等価性を比較
   */
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeaAnalysisResult &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.growthStage == growthStage &&
        other.healthStatus == healthStatus &&
        other.confidence == confidence &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /**
   * ハッシュコードを生成
   */
  @override
  int get hashCode {
    return Object.hash(
      id,
      imagePath,
      growthStage,
      healthStatus,
      confidence,
      comment,
      createdAt,
      updatedAt,
    );
  }

  /**
   * 文字列表現
   */
  @override
  String toString() {
    return 'TeaAnalysisResult(id: $id, imagePath: $imagePath, growthStage: $growthStage, healthStatus: $healthStatus, confidence: $confidence, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /**
   * 今日の解析結果かどうかを判定
   */
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  /**
   * 信頼度が高いかどうかを判定
   */
  bool get isHighConfidence {
    return confidence >= 0.8;
  }

  /**
   * 健康状態が良好かどうかを判定
   */
  bool get isHealthy {
    return healthStatus == '健康';
  }
}

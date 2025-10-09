import '../../domain/entities/tea_analysis_result.dart';

/**
 * 茶葉解析結果のデータモデル
 * データ層とドメイン層の変換を担当
 */
class TeaAnalysisResultModel {
  final String id;
  final String imagePath;
  final String growthStage;
  final String healthStatus;
  final double confidence;
  final String? comment;
  final DateTime timestamp;

  const TeaAnalysisResultModel({
    required this.id,
    required this.imagePath,
    required this.growthStage,
    required this.healthStatus,
    required this.confidence,
    this.comment,
    required this.timestamp,
  });

  /**
   * エンティティからデータモデルに変換
   */
  factory TeaAnalysisResultModel.fromEntity(TeaAnalysisResult entity) {
    return TeaAnalysisResultModel(
      id: entity.id,
      imagePath: entity.imagePath,
      growthStage: entity.growthStage,
      healthStatus: entity.healthStatus,
      confidence: entity.confidence,
      comment: entity.comment,
      timestamp: entity.timestamp,
    );
  }

  /**
   * データモデルからエンティティに変換
   */
  TeaAnalysisResult toEntity() {
    return TeaAnalysisResult(
      id: id,
      imagePath: imagePath,
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: confidence,
      comment: comment,
      timestamp: timestamp,
    );
  }

  /**
   * Mapからデータモデルに変換
   */
  factory TeaAnalysisResultModel.fromMap(Map<String, dynamic> map) {
    return TeaAnalysisResultModel(
      id: map['id'] as String,
      imagePath: map['image_path'] as String,
      growthStage: map['growth_stage'] as String,
      healthStatus: map['health_status'] as String,
      confidence: map['confidence'] as double,
      comment: map['comment'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  /**
   * データモデルからMapに変換
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'growth_stage': growthStage,
      'health_status': healthStatus,
      'confidence': confidence,
      'comment': comment,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /**
   * データモデルの等価性を比較
   */
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeaAnalysisResultModel &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.growthStage == growthStage &&
        other.healthStatus == healthStatus &&
        other.confidence == confidence &&
        other.comment == comment &&
        other.timestamp == timestamp;
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
      timestamp,
    );
  }

  /**
   * 文字列表現
   */
  @override
  String toString() {
    return 'TeaAnalysisResultModel(id: $id, imagePath: $imagePath, growthStage: $growthStage, healthStatus: $healthStatus, confidence: $confidence, comment: $comment, timestamp: $timestamp)';
  }
}
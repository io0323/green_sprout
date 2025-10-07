import '../../core/constants/app_constants.dart';
import '../../domain/entities/tea_analysis_result.dart';

/**
 * 茶葉解析結果のデータモデル
 * SQLiteデータベースとのやり取りに使用
 */
class TeaAnalysisResultModel {
  final int? id;
  final String imagePath;
  final String growthStage;
  final String healthStatus;
  final double confidence;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeaAnalysisResultModel({
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
   * MapからTeaAnalysisResultModelオブジェクトを作成
   */
  factory TeaAnalysisResultModel.fromMap(Map<String, dynamic> map) {
    return TeaAnalysisResultModel(
      id: map['id'],
      imagePath: map['image_path'],
      growthStage: map['growth_stage'],
      healthStatus: map['health_status'],
      confidence: map['confidence'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /**
   * TeaAnalysisResultModelオブジェクトをMapに変換
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'growth_stage': growthStage,
      'health_status': healthStatus,
      'confidence': confidence,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /**
   * ドメインエンティティからTeaAnalysisResultModelを作成
   */
  factory TeaAnalysisResultModel.fromEntity(TeaAnalysisResult entity) {
    return TeaAnalysisResultModel(
      id: entity.id,
      imagePath: entity.imagePath,
      growthStage: entity.growthStage,
      healthStatus: entity.healthStatus,
      confidence: entity.confidence,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /**
   * TeaAnalysisResultModelをドメインエンティティに変換
   */
  TeaAnalysisResult toEntity() {
    return TeaAnalysisResult(
      id: id,
      imagePath: imagePath,
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: confidence,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /**
   * コメントを更新した新しいインスタンスを作成
   */
  TeaAnalysisResultModel copyWith({
    int? id,
    String? imagePath,
    String? growthStage,
    String? healthStatus,
    double? confidence,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeaAnalysisResultModel(
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
    return other is TeaAnalysisResultModel &&
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
    return 'TeaAnalysisResultModel(id: $id, imagePath: $imagePath, growthStage: $growthStage, healthStatus: $healthStatus, confidence: $confidence, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/analysis_result.dart';

/**
 * 解析結果ウィジェット
 * 解析結果を表示するウィジェット
 */
class AnalysisResultWidget extends StatelessWidget {
  final AnalysisResult result;
  final String imagePath;

  const AnalysisResultWidget({
    super.key,
    required this.result,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '茶葉解析結果',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 画像表示
          Center(
            child: Semantics(
              label: '撮影した茶葉の画像',
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 解析結果
          Text(
            '解析結果',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 成長状態
          _buildResultItem(
            '成長状態',
            result.growthStage,
            _getGrowthStageIcon(result.growthStage),
            _getGrowthStageColor(result.growthStage),
          ),
          
          const SizedBox(height: 12),
          
          // 健康状態
          _buildResultItem(
            '健康状態',
            result.healthStatus,
            _getHealthStatusIcon(result.healthStatus),
            _getHealthStatusColor(result.healthStatus),
          ),
          
          const SizedBox(height: 12),
          
          // 信頼度
          _buildResultItem(
            '信頼度',
            '${(result.confidence * 100).toStringAsFixed(1)}%',
            Icons.analytics_outlined,
            Colors.blue,
          ),
          
          const SizedBox(height: 24),
          
          // 信頼度バー
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '解析の信頼度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: '信頼度 ${(result.confidence * 100).toStringAsFixed(1)}%',
                child: LinearProgressIndicator(
                  value: result.confidence,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getConfidenceColor(result.confidence),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getConfidenceDescription(result.confidence),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGrowthStageIcon(String stage) {
    switch (stage) {
      case '芽':
        return Icons.eco_outlined;
      case '若葉':
        return Icons.eco_outlined;
      case '成葉':
        return Icons.local_florist_outlined;
      case '老葉':
        return Icons.nature_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getGrowthStageColor(String stage) {
    switch (stage) {
      case '芽':
        return Colors.lightGreen;
      case '若葉':
        return Colors.green;
      case '成葉':
        return Colors.teal;
      case '老葉':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getHealthStatusIcon(String status) {
    switch (status) {
      case '健康':
        return Icons.check_circle_outline;
      case '軽微な損傷':
        return Icons.warning_outlined;
      case '損傷':
        return Icons.error_outline;
      case '病気':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status) {
      case '健康':
        return Colors.green;
      case '軽微な損傷':
        return Colors.orange;
      case '損傷':
        return Colors.red;
      case '病気':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /**
   * 信頼度に基づく説明文を取得
   */
  String _getConfidenceDescription(double confidence) {
    if (confidence >= 0.9) {
      return '非常に高い信頼度です。解析結果は非常に正確です。';
    } else if (confidence >= 0.8) {
      return '高い信頼度です。解析結果は正確です。';
    } else if (confidence >= 0.6) {
      return '中程度の信頼度です。解析結果は概ね正確です。';
    } else {
      return '低い信頼度です。解析結果の確認をお勧めします。';
    }
  }
}

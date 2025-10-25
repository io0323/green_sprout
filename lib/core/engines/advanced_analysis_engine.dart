import 'package:image/image.dart' as img;
import '../../src/tflite_interface.dart';
import '../utils/advanced_image_processor.dart';
import '../../features/tea_analysis/domain/entities/analysis_result.dart';

/// 高度なAI解析エンジン
/// 複数の解析手法を組み合わせた高精度な茶葉解析システム
class AdvancedAnalysisEngine {
  TfliteWrapper? _primaryModel;
  TfliteWrapper? _secondaryModel;
  bool _isInitialized = false;

  /// 解析エンジンを初期化
  Future<void> initialize() async {
    try {
      // プライマリモデル（成長状態分類）の読み込み
      _primaryModel = TfliteWrapper.create();

      // セカンダリモデル（健康状態分類）の読み込み（将来の実装）
      // _secondaryModel = TfliteWrapper.create();

      _isInitialized = true;
    } catch (e) {
      // フォールバックモードで初期化
      _isInitialized = true;
    }
  }

  /// 高度な画像解析を実行
  /// 複数の解析手法を組み合わせた高精度解析
  Future<AnalysisResult> analyzeImage(img.Image image) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 1. 画像品質の評価
    final quality = AdvancedImageProcessor.assessImageQuality(image);

    // 2. 画像の前処理
    final processedImage = AdvancedImageProcessor.preprocessImage(image);

    // 3. 複数の解析手法を実行
    final results = await Future.wait([
      _analyzeWithPrimaryModel(processedImage),
      _analyzeWithFeatureExtraction(processedImage),
      _analyzeWithEnsembleMethod(processedImage),
    ]);

    // 4. 結果の統合と信頼度の計算
    return _combineResults(results, quality);
  }

  /// プライマリモデルによる解析
  Future<AnalysisResult> _analyzeWithPrimaryModel(img.Image image) async {
    if (_primaryModel == null) {
      return _getFallbackResult();
    }

    try {
      // 画像をFloat32Listに変換
      final input = AdvancedImageProcessor.imageToFloat32List(image);

      // モデルの入力形状を取得
      final inputShape = _primaryModel!.getInputTensor(0).shape;
      final outputShape = _primaryModel!.getOutputTensor(0).shape;

      // 入力データをリシェイプ
      final reshapedInput = input.reshape(inputShape);
      final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(outputShape);

      // 推論実行
      _primaryModel!.run(reshapedInput, output);

      // 結果を解析
      return _parsePrimaryModelOutput(output.cast<List<double>>());
    } catch (e) {
      return _getFallbackResult();
    }
  }

  /// 特徴抽出による解析
  Future<AnalysisResult> _analyzeWithFeatureExtraction(img.Image image) async {
    final features = AdvancedImageProcessor.extractFeatures(image);

    // 特徴量ベースの分類ロジック
    final growthStage = _classifyGrowthStage(features);
    final healthStatus = _classifyHealthStatus(features);

    return AnalysisResult(
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: 0.75, // 特徴量ベースの解析の信頼度
    );
  }

  /// アンサンブル手法による解析
  Future<AnalysisResult> _analyzeWithEnsembleMethod(img.Image image) async {
    // 複数の小さなモデルやルールベースの解析を組み合わせ
    final results = <AnalysisResult>[];

    // 1. 色相ベースの解析
    results.add(_analyzeByColor(image));

    // 2. テクスチャベースの解析
    results.add(_analyzeByTexture(image));

    // 3. 形状ベースの解析
    results.add(_analyzeByShape(image));

    // 結果を統合
    return _combineEnsembleResults(results);
  }

  /// 色相ベースの解析
  AnalysisResult _analyzeByColor(img.Image image) {
    final features = AdvancedImageProcessor.extractFeatures(image);

    String growthStage;
    String healthStatus;
    double confidence = 0.6;

    // 色相による成長状態の判定
    if (features.averageHue < 60) {
      growthStage = '芽';
    } else if (features.averageHue < 120) {
      growthStage = '若葉';
    } else if (features.averageHue < 180) {
      growthStage = '成葉';
    } else {
      growthStage = '老葉';
    }

    // 彩度と明度による健康状態の判定
    if (features.averageSaturation > 0.5 && features.averageLightness > 0.4) {
      healthStatus = '健康';
      confidence = 0.8;
    } else if (features.averageSaturation > 0.3) {
      healthStatus = '軽微な損傷';
      confidence = 0.7;
    } else {
      healthStatus = '損傷';
      confidence = 0.6;
    }

    return AnalysisResult(
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: confidence,
    );
  }

  /// テクスチャベースの解析
  AnalysisResult _analyzeByTexture(img.Image image) {
    // グレースケール変換
    final gray = img.grayscale(image);

    // エッジ検出
    final edges =
        img.convolution(gray, filter: [-1, -1, -1, -1, 8, -1, -1, -1, -1]);

    // エッジ密度の計算
    final edgePixels = edges.getBytes();
    int edgeCount = 0;

    for (final pixel in edgePixels) {
      if (pixel > 128) edgeCount++;
    }

    final edgeDensity = edgeCount / edgePixels.length;

    String growthStage;
    String healthStatus;
    double confidence = 0.65;

    // エッジ密度による判定
    if (edgeDensity > 0.3) {
      growthStage = '若葉';
      healthStatus = '健康';
      confidence = 0.8;
    } else if (edgeDensity > 0.15) {
      growthStage = '成葉';
      healthStatus = '軽微な損傷';
      confidence = 0.7;
    } else {
      growthStage = '老葉';
      healthStatus = '損傷';
      confidence = 0.6;
    }

    return AnalysisResult(
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: confidence,
    );
  }

  /// 形状ベースの解析
  AnalysisResult _analyzeByShape(img.Image image) {
    // 輪郭検出
    final contours = _detectContours(image);

    String growthStage;
    String healthStatus;
    double confidence = 0.6;

    // 輪郭の複雑さによる判定
    if (contours.length > 10) {
      growthStage = '若葉';
      healthStatus = '健康';
      confidence = 0.75;
    } else if (contours.length > 5) {
      growthStage = '成葉';
      healthStatus = '軽微な損傷';
      confidence = 0.65;
    } else {
      growthStage = '老葉';
      healthStatus = '損傷';
      confidence = 0.55;
    }

    return AnalysisResult(
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: confidence,
    );
  }

  /// 輪郭検出
  List<Contour> _detectContours(img.Image image) {
    // 簡易的な輪郭検出（実際の実装ではより高度なアルゴリズムを使用）
    final gray = img.grayscale(image);
    final edges =
        img.convolution(gray, filter: [-1, -1, -1, -1, 8, -1, -1, -1, -1]);

    // 輪郭点を検出
    final contours = <Contour>[];
    final pixels = edges.getBytes();

    for (int y = 1; y < edges.height - 1; y++) {
      for (int x = 1; x < edges.width - 1; x++) {
        final index = y * edges.width + x;
        if (pixels[index] > 128) {
          contours.add(Contour(x, y));
        }
      }
    }

    return contours;
  }

  /// プライマリモデルの出力を解析
  AnalysisResult _parsePrimaryModelOutput(List<List<double>> output) {
    // 出力の形状に応じて解析
    if (output.isEmpty || output[0].isEmpty) {
      return _getFallbackResult();
    }

    final probabilities = output[0];

    // 成長状態の分類
    final growthStageIndex = _findMaxIndex(probabilities.take(4).toList());
    final growthStages = ['芽', '若葉', '成葉', '老葉'];
    final growthStage = growthStages[growthStageIndex];

    // 健康状態の分類
    final healthIndex = _findMaxIndex(probabilities.skip(4).take(4).toList());
    final healthStatuses = ['健康', '軽微な損傷', '損傷', '病気'];
    final healthStatus = healthStatuses[healthIndex];

    // 信頼度の計算
    final confidence = probabilities.reduce((a, b) => a > b ? a : b);

    return AnalysisResult(
      growthStage: growthStage,
      healthStatus: healthStatus,
      confidence: confidence,
    );
  }

  /// 成長状態の分類
  String _classifyGrowthStage(ImageFeatures features) {
    if (features.averageHue < 60 && features.averageSaturation > 0.6) {
      return '芽';
    } else if (features.averageHue < 120 && features.averageLightness > 0.5) {
      return '若葉';
    } else if (features.averageHue < 180) {
      return '成葉';
    } else {
      return '老葉';
    }
  }

  /// 健康状態の分類
  String _classifyHealthStatus(ImageFeatures features) {
    if (features.averageSaturation > 0.5 && features.averageLightness > 0.4) {
      return '健康';
    } else if (features.averageSaturation > 0.3) {
      return '軽微な損傷';
    } else if (features.averageLightness < 0.3) {
      return '病気';
    } else {
      return '損傷';
    }
  }

  /// アンサンブル結果の統合
  AnalysisResult _combineEnsembleResults(List<AnalysisResult> results) {
    // 重み付き投票
    final growthStageVotes = <String, double>{};
    final healthStatusVotes = <String, double>{};

    for (final result in results) {
      growthStageVotes[result.growthStage] =
          (growthStageVotes[result.growthStage] ?? 0) + result.confidence;
      healthStatusVotes[result.healthStatus] =
          (healthStatusVotes[result.healthStatus] ?? 0) + result.confidence;
    }

    // 最も高いスコアの結果を選択
    final bestGrowthStage = growthStageVotes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final bestHealthStatus = healthStatusVotes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // 平均信頼度を計算
    final avgConfidence =
        results.map((r) => r.confidence).reduce((a, b) => a + b) /
            results.length;

    return AnalysisResult(
      growthStage: bestGrowthStage,
      healthStatus: bestHealthStatus,
      confidence: avgConfidence,
    );
  }

  /// 複数の結果を統合
  AnalysisResult _combineResults(
      List<AnalysisResult> results, ImageQuality quality) {
    // 画像品質に基づく重み付け
    final qualityWeight = quality.overallScore;

    // 重み付き平均を計算
    double totalWeight = 0;
    final growthStageVotes = <String, double>{};
    final healthStatusVotes = <String, double>{};

    for (int i = 0; i < results.length; i++) {
      final weight = qualityWeight * (i == 0 ? 0.5 : 0.25); // プライマリモデルに高い重み
      totalWeight += weight;

      growthStageVotes[results[i].growthStage] =
          (growthStageVotes[results[i].growthStage] ?? 0) +
              weight * results[i].confidence;
      healthStatusVotes[results[i].healthStatus] =
          (healthStatusVotes[results[i].healthStatus] ?? 0) +
              weight * results[i].confidence;
    }

    // 正規化
    growthStageVotes.updateAll((key, value) => value / totalWeight);
    healthStatusVotes.updateAll((key, value) => value / totalWeight);

    // 最適な結果を選択
    final bestGrowthStage = growthStageVotes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final bestHealthStatus = healthStatusVotes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // 最終信頼度の計算
    final finalConfidence = (growthStageVotes[bestGrowthStage]! +
            healthStatusVotes[bestHealthStatus]!) /
        2;

    return AnalysisResult(
      growthStage: bestGrowthStage,
      healthStatus: bestHealthStatus,
      confidence: finalConfidence.clamp(0.0, 1.0),
    );
  }

  /// 最大値のインデックスを取得
  int _findMaxIndex(List<double> list) {
    int maxIndex = 0;
    double maxValue = list[0];

    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  /// フォールバック結果
  AnalysisResult _getFallbackResult() {
    return const AnalysisResult(
      growthStage: '成葉',
      healthStatus: '健康',
      confidence: 0.5,
    );
  }

  /// リソースの解放
  void dispose() {
    _primaryModel?.close();
    _secondaryModel?.close();
    _isInitialized = false;
  }
}

/// 輪郭点
class Contour {
  final int x;
  final int y;

  Contour(this.x, this.y);
}

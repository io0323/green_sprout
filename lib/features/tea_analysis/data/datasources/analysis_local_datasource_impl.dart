import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:image/image.dart' as img;

// Use the platform-abstracted TFLite service
// This automatically selects native or web stub based on platform
import '../../../../ml/tflite_interface.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_result.dart';
import 'analysis_local_datasource.dart';

/// AI解析のローカルデータソースの実装クラス
/// TensorFlow Liteを使用した画像解析機能
class AnalysisLocalDataSourceImpl implements AnalysisLocalDataSource {
  dynamic _interpreter; // Platform-agnostic interpreter
  bool _isModelLoaded = false;
  bool _isTFLiteAvailable = false;

  @override
  Future<Either<Failure, AnalysisResult>> analyzeImage(File imageFile) async {
    try {
      // モデルが読み込まれていない場合は読み込む
      if (!_isModelLoaded) {
        final loadResult = await loadModel();
        if (loadResult.isLeft()) {
          return Left(loadResult.fold((l) => l, (r) => throw Exception()));
        }
      }

      // 画像を読み込んで前処理
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return const Left(TFLiteFailure('画像の読み込みに失敗しました'));
      }

      // 画像をリサイズ
      final resizedImage = img.copyResize(
        image,
        width: AppConstants.inputImageSize,
        height: AppConstants.inputImageSize,
      );

      if (_isTFLiteAvailable) {
        // TensorFlow Liteが利用可能な場合の実装
        return _analyzeWithTFLite(resizedImage);
      } else {
        // フォールバック：画像特徴量ベースの簡易解析
        return _analyzeWithFallback(resizedImage);
      }
    } catch (e) {
      return Left(TFLiteFailure('画像解析に失敗しました: $e'));
    }
  }

  @override
  bool get isModelLoaded => _isModelLoaded;

  @override
  Future<Either<Failure, Unit>> loadModel() async {
    try {
      // Check if TFLite is available on this platform
      _isTFLiteAvailable = TfliteService.isAvailable;

      if (!_isTFLiteAvailable) {
        // Web platform or TFLite not available - use fallback
        _isModelLoaded = true;
        return const Right(unit);
      }

      // TensorFlow Liteモデルの読み込み
      _interpreter = await TfliteService.createInterpreterFromAsset(
        AppConstants.modelPath,
      );

      if (_interpreter != null) {
        _isModelLoaded = true;
        return const Right(unit);
      } else {
        // Model loading failed - use fallback
        _isTFLiteAvailable = false;
        _isModelLoaded = true;
        return const Right(unit);
      }
    } catch (e) {
      // Model loading failed - use fallback
      _isTFLiteAvailable = false;
      _isModelLoaded = true;
      return const Right(unit);
    }
  }

  /// TensorFlow Liteを使用した画像解析
  /// 実際のAIモデルによる茶葉の成長状態と健康状態の分類
  Future<Either<Failure, AnalysisResult>> _analyzeWithTFLite(
      img.Image image) async {
    try {
      if (_interpreter == null) {
        return const Left(TFLiteFailure('TensorFlow Liteモデルが読み込まれていません'));
      }

      // 画像をRGB配列に変換
      final input = _imageToByteListFloat32(image);

      // モデルの入力と出力の形状を取得
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // 入力データを正しい形状にリシェイプ
      final reshapedInput = _reshape(input, inputShape);
      final output = _createNestedList(outputShape, 0.0);

      // 推論実行
      _interpreter!.run(reshapedInput, output);

      // 結果を解析
      final result = _parseModelOutput(output);

      return Right(result);
    } catch (e) {
      return Left(TFLiteFailure('TensorFlow Lite解析に失敗しました: $e'));
    }
  }

  /// フォールバック：画像特徴量ベースの簡易解析
  Future<Either<Failure, AnalysisResult>> _analyzeWithFallback(
      img.Image image) async {
    try {
      // 画像の平均色を計算
      double totalR = 0, totalG = 0, totalB = 0;
      int pixelCount = 0;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          totalR += pixel.r;
          totalG += pixel.g;
          totalB += pixel.b;
          pixelCount++;
        }
      }

      final avgR = totalR / pixelCount;
      final avgG = totalG / pixelCount;
      final avgB = totalB / pixelCount;

      // 色に基づく簡易分類
      final brightness = (avgR + avgG + avgB) / 3;
      final greenness = avgG / (avgR + avgG + avgB + 1);

      String growthStage;
      String healthStatus;
      double confidence;

      if (brightness < 100) {
        growthStage = GrowthStageConstants.oldLeaf;
        healthStatus = greenness > 0.4
            ? HealthStatusConstants.healthy
            : HealthStatusConstants.damaged;
        confidence = 0.75;
      } else if (brightness < 150) {
        growthStage = GrowthStageConstants.matureLeaf;
        healthStatus = greenness > 0.45
            ? HealthStatusConstants.healthy
            : HealthStatusConstants.slightlyDamaged;
        confidence = 0.80;
      } else if (brightness < 200) {
        growthStage = GrowthStageConstants.youngLeaf;
        healthStatus = greenness > 0.5
            ? HealthStatusConstants.healthy
            : HealthStatusConstants.slightlyDamaged;
        confidence = 0.85;
      } else {
        growthStage = GrowthStageConstants.bud;
        healthStatus = greenness > 0.55
            ? HealthStatusConstants.healthy
            : HealthStatusConstants.slightlyDamaged;
        confidence = 0.90;
      }

      return Right(AnalysisResult(
        growthStage: growthStage,
        healthStatus: healthStatus,
        confidence: confidence,
      ));
    } catch (e) {
      return Left(TFLiteFailure('フォールバック解析に失敗しました: $e'));
    }
  }

  /// 画像をTensorFlow Liteの入力形式（Float32配列）に変換
  /// 224x224x3のRGB画像を正規化して配列に変換
  List<double> _imageToByteListFloat32(img.Image image) {
    final bytes = Float32List(
        AppConstants.inputImageSize * AppConstants.inputImageSize * 3);
    int bufferIndex = 0;

    for (int y = 0; y < AppConstants.inputImageSize; y++) {
      for (int x = 0; x < AppConstants.inputImageSize; x++) {
        final pixel = image.getPixel(x, y);
        // RGB値を0-1の範囲に正規化
        bytes[bufferIndex++] = pixel.r / 255.0;
        bytes[bufferIndex++] = pixel.g / 255.0;
        bytes[bufferIndex++] = pixel.b / 255.0;
      }
    }

    return bytes;
  }

  /// モデルの出力を解析して茶葉の状態を判定
  /// 8クラス分類（成長状態4クラス × 健康状態2クラス）
  AnalysisResult _parseModelOutput(List output) {
    // 出力配列から確率を取得
    final probabilities = output[0] as List<double>;

    // クラス名の定義
    const growthStages = [
      GrowthStageConstants.bud,
      GrowthStageConstants.youngLeaf,
      GrowthStageConstants.matureLeaf,
      GrowthStageConstants.oldLeaf
    ];
    const healthStatuses = [
      HealthStatusConstants.healthy,
      HealthStatusConstants.damaged
    ];

    // 最も高い確率のインデックスを取得
    int maxIndex = 0;
    double maxProb = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    // インデックスから成長状態と健康状態を計算
    final growthStageIndex = maxIndex ~/ 2;
    final healthStatusIndex = maxIndex % 2;

    return AnalysisResult(
      growthStage: growthStages[growthStageIndex],
      healthStatus: healthStatuses[healthStatusIndex],
      confidence: maxProb,
    );
  }

  /// リソースの解放
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Helper: reshape list to desired shape
  List _reshape(List input, List<int> shape) {
    // Simple implementation - flatten to 1D then rebuild
    final flattened = input.expand((e) => e is List ? e : [e]).toList();
    return _createNestedList(shape, flattened);
  }

  /// Helper: create nested list based on shape
  dynamic _createNestedList(List<int> shape, dynamic fill) {
    if (shape.length == 1) {
      return List.filled(shape[0], fill);
    }
    final first = shape[0];
    final rest = shape.sublist(1);
    return List.generate(first, (_) => _createNestedList(rest, fill));
  }
}

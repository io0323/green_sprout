import 'package:dartz/dartz.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/analysis_result.dart';
import '../datasources/analysis_local_datasource.dart';

/// AI解析のローカルデータソースの実装
class AnalysisLocalDataSourceImpl implements AnalysisLocalDataSource {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  @override
  Future<Either<Failure, AnalysisResult>> analyzeImage(String imagePath) async {
    try {
      // モデルが読み込まれていない場合は読み込む
      if (!_isModelLoaded) {
        final loadResult = await loadModel();
        if (loadResult.isLeft()) {
          return Left(loadResult.fold((l) => l, (r) => throw Exception()));
        }
      }

      // 画像を読み込んで前処理
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return Left(TFLiteFailure('画像の読み込みに失敗しました'));
      }

      // 画像をリサイズ
      final resizedImage = img.copyResize(
        image,
        width: AppConstants.inputImageSize,
        height: AppConstants.inputImageSize,
      );

      // 画像をテンソルに変換
      final input = _preprocessImage(resizedImage);

      // 推論実行
      final output = List.filled(1, List.filled(4, 0.0)).reshape([1, 4]);
      _interpreter!.run(input, output);

      // 結果を解析
      final result = _parseOutput(output[0]);

      return Right(result);
    } catch (e) {
      return Left(TFLiteFailure('画像解析に失敗しました: $e'));
    }
  }

  @override
  Future<bool> isModelLoaded() async {
    return _isModelLoaded;
  }

  @override
  Future<Either<Failure, void>> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);
      _isModelLoaded = true;
      return Right(null);
    } catch (e) {
      return Left(TFLiteFailure('モデルの読み込みに失敗しました: $e'));
    }
  }

  /// 画像を前処理してテンソルに変換
  List<List<List<double>>> _preprocessImage(img.Image image) {
    final input = List.generate(
      AppConstants.inputImageSize,
      (i) => List.generate(
        AppConstants.inputImageSize,
        (j) => List.generate(AppConstants.inputChannels, (k) => 0.0),
      ),
    );

    for (int i = 0; i < AppConstants.inputImageSize; i++) {
      for (int j = 0; j < AppConstants.inputImageSize; j++) {
        final pixel = image.getPixel(j, i);
        input[i][j][0] = img.getRed(pixel) / 255.0;   // R
        input[i][j][1] = img.getGreen(pixel) / 255.0; // G
        input[i][j][2] = img.getBlue(pixel) / 255.0;  // B
      }
    }

    return input;
  }

  /// 推論結果を解析してAnalysisResultに変換
  AnalysisResult _parseOutput(List<double> output) {
    // 出力の解釈（例：成長状態と健康状態の分類）
    final growthStageIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    final healthStatusIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    
    final growthStages = ['芽', '若葉', '成葉', '老葉'];
    final healthStatuses = ['健康', '軽微な損傷', '損傷', '病気'];
    
    return AnalysisResult(
      growthStage: growthStages[growthStageIndex],
      healthStatus: healthStatuses[healthStatusIndex],
      confidence: output[growthStageIndex],
      timestamp: DateTime.now(),
    );
  }
}
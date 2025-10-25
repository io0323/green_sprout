import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/analysis_result.dart';

/// AI解析リポジトリの抽象クラス
/// TensorFlow Liteモデルを使用した画像解析の契約を定義
abstract class AnalysisRepository {
  /// TFLiteモデルをロードする
  Future<Either<Failure, Unit>> loadModel();

  /// 画像を解析し、結果を返す
  Future<Either<Failure, AnalysisResult>> analyzeImage(File imageFile);

  /// モデルが読み込まれているかチェック
  bool get isModelLoaded;
}

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_result.dart';

/// AI解析のローカルデータソースの抽象クラス
/// TFLiteモデルの呼び出しや画像の前処理などを定義
abstract class AnalysisLocalDataSource {
  /// 画像を解析し、結果を返す
  Future<Either<Failure, AnalysisResult>> analyzeImage(File imageFile);

  /// モデルが読み込まれているかチェック
  bool get isModelLoaded;

  /// TFLiteモデルをロードする
  Future<Either<Failure, Unit>> loadModel();
}

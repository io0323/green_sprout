import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// 高度な画像前処理と特徴抽出ユーティリティ
/// AIモデルの精度向上のための画像処理機能
class AdvancedImageProcessor {
  static const int _targetSize = 224;
  static const int _channels = 3;

  /// 画像の高度な前処理
  /// ノイズ除去、コントラスト調整、正規化を含む
  static img.Image preprocessImage(img.Image image) {
    // 1. ノイズ除去（ガウシアンフィルタ）
    var processed = img.gaussianBlur(image, radius: 1);

    // 2. コントラスト調整
    processed = img.adjustColor(processed, contrast: 1.2);

    // 3. 明度調整
    processed = img.adjustColor(processed, brightness: 1.1);

    // 4. シャープネス向上
    processed =
        img.convolution(processed, filter: [-1, -1, -1, -1, 9, -1, -1, -1, -1]);

    // 5. リサイズ（アスペクト比を保持）
    processed = _resizeWithAspectRatio(processed, _targetSize);

    return processed;
  }

  /// アスペクト比を保持したリサイズ
  static img.Image _resizeWithAspectRatio(img.Image image, int targetSize) {
    final int width = image.width;
    final int height = image.height;

    // 既に目標サイズの場合はそのまま返す
    if (width == targetSize && height == targetSize) {
      return image;
    }

    // 長辺を目標サイズに合わせてリサイズ（アスペクト比を保持）
    int newWidth, newHeight;
    if (width >= height) {
      // 横長の場合：幅を目標サイズに、高さを比例的に縮小
      newWidth = targetSize;
      newHeight = (height * targetSize / width).round();
    } else {
      // 縦長の場合：高さを目標サイズに、幅を比例的に縮小
      newHeight = targetSize;
      newWidth = (width * targetSize / height).round();
    }

    // リサイズ
    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// 画像をTensorFlow Lite用のFloat32Listに変換
  /// 正規化とチャンネル順序の調整を含む
  static Float32List imageToFloat32List(img.Image image) {
    final int width = image.width;
    final int height = image.height;
    final int size = width * height * _channels;
    final Float32List floatList = Float32List(size);

    final pixels = image.getBytes();
    final int actualPixelCount = pixels.length ~/ 4; // RGBA形式

    // 実際のピクセル数を使用（画像処理後のサイズに基づく）
    int index = 0;
    final int pixelCountToProcess =
        actualPixelCount < width * height ? actualPixelCount : width * height;

    for (int i = 0; i < pixelCountToProcess; i++) {
      final pixelIndex = i * 4;

      // RGB値を取得（0-255から0-1に正規化）
      final double r = pixels[pixelIndex] / 255.0;
      final double g = pixels[pixelIndex + 1] / 255.0;
      final double b = pixels[pixelIndex + 2] / 255.0;

      // ImageNetの平均と標準偏差で正規化
      floatList[index] = (r - 0.485) / 0.229; // R
      floatList[index + 1] = (g - 0.456) / 0.224; // G
      floatList[index + 2] = (b - 0.406) / 0.225; // B

      index += 3;
    }

    // 残りのピクセルを0で埋める（画像が小さい場合）
    while (index < size) {
      floatList[index++] = 0.0;
      floatList[index++] = 0.0;
      floatList[index++] = 0.0;
    }

    return floatList;
  }

  /// 画像の品質を評価
  /// ぼやけ、明度、コントラストを評価
  static ImageQuality assessImageQuality(img.Image image) {
    // 1. ぼやけの評価（ラプラシアン分散）
    final blurScore = _calculateBlurScore(image);

    // 2. 明度の評価
    final brightnessScore = _calculateBrightnessScore(image);

    // 3. コントラストの評価
    final contrastScore = _calculateContrastScore(image);

    // 4. 総合スコアの計算
    final overallScore =
        (blurScore * 0.4 + brightnessScore * 0.3 + contrastScore * 0.3);

    return ImageQuality(
      blurScore: blurScore,
      brightnessScore: brightnessScore,
      contrastScore: contrastScore,
      overallScore: overallScore,
    );
  }

  /// ぼやけスコアの計算（ラプラシアン分散）
  static double _calculateBlurScore(img.Image image) {
    // グレースケールに変換
    final gray = img.grayscale(image);

    // ラプラシアンフィルタを適用
    final laplacian =
        img.convolution(gray, filter: [0, 1, 0, 1, -4, 1, 0, 1, 0]);

    // 分散を計算
    final pixels = laplacian.getBytes();
    double sum = 0;
    double sumSquared = 0;

    for (final pixel in pixels) {
      sum += pixel;
      sumSquared += pixel * pixel;
    }

    final mean = sum / pixels.length;
    final variance = (sumSquared / pixels.length) - (mean * mean);

    // スコアを0-1の範囲に正規化
    return (variance / 10000).clamp(0.0, 1.0);
  }

  /// 明度スコアの計算
  static double _calculateBrightnessScore(img.Image image) {
    final pixels = image.getBytes();
    double totalBrightness = 0;

    for (int i = 0; i < pixels.length; i += 4) {
      // RGBの平均を計算
      final brightness = (pixels[i] + pixels[i + 1] + pixels[i + 2]) / 3;
      totalBrightness += brightness;
    }

    final averageBrightness = totalBrightness / (pixels.length / 4);

    // 理想的な明度（128）からの偏差を計算
    final deviation = (averageBrightness - 128).abs() / 128;

    return (1.0 - deviation).clamp(0.0, 1.0);
  }

  /// コントラストスコアの計算
  static double _calculateContrastScore(img.Image image) {
    final pixels = image.getBytes();
    int minBrightness = 255;
    int maxBrightness = 0;

    for (int i = 0; i < pixels.length; i += 4) {
      final brightness = (pixels[i] + pixels[i + 1] + pixels[i + 2]) ~/ 3;
      minBrightness = minBrightness < brightness ? minBrightness : brightness;
      maxBrightness = maxBrightness > brightness ? maxBrightness : brightness;
    }

    final contrast = maxBrightness - minBrightness;

    // スコアを0-1の範囲に正規化
    return (contrast / 255).clamp(0.0, 1.0);
  }

  /// 画像の特徴量を抽出
  /// 色相、彩度、明度の統計情報
  static ImageFeatures extractFeatures(img.Image image) {
    final pixels = image.getBytes();
    double totalH = 0, totalS = 0, totalL = 0;
    int pixelCount = 0;

    for (int i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];

      // RGBからHSLに変換
      final hsl = _rgbToHsl(r, g, b);

      totalH += hsl.h;
      totalS += hsl.s;
      totalL += hsl.l;
      pixelCount++;
    }

    return ImageFeatures(
      averageHue: totalH / pixelCount,
      averageSaturation: totalS / pixelCount,
      averageLightness: totalL / pixelCount,
      pixelCount: pixelCount,
    );
  }

  /// RGBからHSLに変換
  static HSL _rgbToHsl(int r, int g, int b) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    final min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);

    double h, s, l;

    l = (max + min) / 2;

    if (max == min) {
      h = s = 0; // 無彩色
    } else {
      final d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      if (max == rf) {
        h = (gf - bf) / d + (gf < bf ? 6 : 0);
      } else if (max == gf) {
        h = (bf - rf) / d + 2;
      } else {
        h = (rf - gf) / d + 4;
      }
      h /= 6;
    }

    return HSL(h * 360, s, l);
  }
}

/// 画像品質の評価結果
class ImageQuality {
  final double blurScore;
  final double brightnessScore;
  final double contrastScore;
  final double overallScore;

  ImageQuality({
    required this.blurScore,
    required this.brightnessScore,
    required this.contrastScore,
    required this.overallScore,
  });

  bool get isGoodQuality => overallScore > 0.7;
  bool get isPoorQuality => overallScore < 0.4;
}

/// 画像の特徴量
class ImageFeatures {
  final double averageHue;
  final double averageSaturation;
  final double averageLightness;
  final int pixelCount;

  ImageFeatures({
    required this.averageHue,
    required this.averageSaturation,
    required this.averageLightness,
    required this.pixelCount,
  });
}

/// HSL色空間
class HSL {
  final double h; // 色相 (0-360)
  final double s; // 彩度 (0-1)
  final double l; // 明度 (0-1)

  HSL(this.h, this.s, this.l);
}

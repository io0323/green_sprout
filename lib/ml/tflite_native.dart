// Native implementation for TFLite functionality
// Uses the actual tflite_flutter package on platforms with FFI support
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;

/// TFLite service for native platforms (Android, iOS, Desktop)
class TfliteService {
  TfliteService._();

  /// Create an interpreter from an asset path
  static Future<tflite.Interpreter?> createInterpreterFromAsset(
      String assetPath) async {
    try {
      return await tflite.Interpreter.fromAsset(assetPath);
    } catch (e) {
      return null; // Model loading failed
    }
  }

  /// Check if TFLite is available on this platform
  static bool get isAvailable => true;
}

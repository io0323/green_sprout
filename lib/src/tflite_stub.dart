import 'tflite_interface.dart';

/// Web stub implementation for TFLite functionality
/// Provides fallback behavior when running on web platform
class TfliteWrapper {
  /// Whether TFLite is available on this platform
  bool get available => false;

  /// Create a TFLite wrapper instance
  /// Returns null on web platform
  static Future<TfliteWrapper?> create() async {
    return null; // Not available on web
  }

  /// Get input tensor information
  /// Throws UnsupportedError on web platform
  TensorInfo getInputTensor(int index) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Get output tensor information
  /// Throws UnsupportedError on web platform
  TensorInfo getOutputTensor(int index) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Run model inference
  /// Throws UnsupportedError on web platform
  void run(Object input, Object output) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Run model inference with input data (convenience method)
  /// Throws UnsupportedError on web platform
  void runModel(List<double> input) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Get model output (convenience method)
  /// Throws UnsupportedError on web platform
  List<List<double>> getModelOutput() {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Dispose resources
  void dispose() {
    // No-op on web
  }
}

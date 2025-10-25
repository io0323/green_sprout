/// Web stub implementation for TFLite functionality
/// Provides fallback behavior when running on web platform
class TfliteWrapper {
  /// Whether TFLite is available on this platform
  bool get available => false;

  /// Create a TFLite wrapper instance
  /// Returns null on web platform
  static TfliteWrapper? create() {
    return null; // Not available on web
  }

  /// Run model inference
  /// Throws UnsupportedError on web platform
  void runModel(List<double> input) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Get model output
  /// Throws UnsupportedError on web platform
  List<List<double>> getModelOutput() {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  /// Dispose resources
  void dispose() {
    // No-op on web
  }
}

// Web stub for TFLite functionality
// Provides safe no-op implementation for Web platform

/// TFLite service for Web platform (stub implementation)
class TfliteService {
  TfliteService._();

  /// Create an interpreter from an asset path (not supported on Web)
  static Future<dynamic> createInterpreterFromAsset(String assetPath) async {
    throw UnsupportedError(
        'TfliteService is not available on the Web platform. '
        'Please use a native build (Android/iOS/Desktop) for TFLite functionality.');
  }

  /// Check if TFLite is available on this platform
  static bool get isAvailable => false;
}

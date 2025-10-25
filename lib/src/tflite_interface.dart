/// TFLite platform abstraction interface
/// Uses conditional imports to provide mobile implementation or web stub
export 'tflite_stub.dart' // default for web
    if (dart.library.io) 'tflite_mobile.dart';

/// Abstract base class for TFLite wrapper
abstract class TfliteWrapper {
  /// Factory that returns the concrete wrapper instance
  static Future<TfliteWrapper?> create() {
    throw UnimplementedError(
        'create() must be implemented by concrete classes');
  }

  /// Whether TFLite is available on this platform
  bool get available;

  /// Get input tensor information
  TensorInfo getInputTensor(int index);

  /// Get output tensor information
  TensorInfo getOutputTensor(int index);

  /// Run model inference
  void run(Object input, Object output);

  /// Run model inference with input data (convenience method)
  void runModel(List<double> input);

  /// Get model output (convenience method)
  List<List<double>> getModelOutput();

  /// Dispose resources
  void dispose();
}

/// Tensor information class
class TensorInfo {
  final List<int> shape;
  final String dtype;

  TensorInfo({required this.shape, required this.dtype});
}

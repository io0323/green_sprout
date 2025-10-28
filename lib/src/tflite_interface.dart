// TFLite platform abstraction interface
// Uses conditional imports to provide mobile implementation or web stub
export 'tflite_stub.dart' // default for web
    if (dart.library.io) 'tflite_mobile.dart';

/// Tensor information class
class TensorInfo {
  final List<int> shape;
  final String dtype;

  TensorInfo({required this.shape, required this.dtype});
}

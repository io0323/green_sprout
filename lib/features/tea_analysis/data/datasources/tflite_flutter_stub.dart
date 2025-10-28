// Stub file for tflite_flutter on Web platform
// Prevents Web build from trying to compile native FFI code

/// Stub Interpreter class for Web platform
class Interpreter {
  factory Interpreter.fromAsset(String path) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  void close() {}
  List<Tensor> getInputTensors() => [];
  List<Tensor> getOutputTensors() => [];
  void run(Object input, Object output) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  // Additional methods used by code
  Tensor getInputTensor(int index) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }

  Tensor getOutputTensor(int index) {
    throw UnsupportedError('TFLite is not supported on Web platform');
  }
}

/// Stub TensorInfo class for Web platform
class Tensor {
  List<int> shape = [];
  String type = '';

  // Add missing methods
  dynamic get data => [];
}

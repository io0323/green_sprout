import 'package:tflite_flutter/tflite_flutter.dart';

/// Mobile implementation for TFLite functionality
/// Provides actual TFLite inference on mobile platforms
class TfliteWrapper {
  final Interpreter _interpreter;
  bool _isDisposed = false;

  TfliteWrapper._(this._interpreter);

  /// Whether TFLite is available on this platform
  bool get available => !_isDisposed;

  /// Create a TFLite wrapper instance
  /// Loads the model from assets
  static TfliteWrapper? create() {
    try {
      final interpreter =
          Interpreter.fromAsset('assets/models/tea_model.tflite');
      return TfliteWrapper._(interpreter);
    } catch (e) {
      return null; // Model loading failed
    }
  }

  /// Run model inference
  /// @param input Input data for the model
  void runModel(List<double> input) {
    if (_isDisposed) {
      throw StateError('TFLite wrapper has been disposed');
    }

    try {
      // Convert input to the format expected by the model
      final inputTensor = [input];
      final outputTensor =
          List.filled(1, List.filled(3, 0.0)); // Assuming 3 outputs

      _interpreter.run(inputTensor, outputTensor);
    } catch (e) {
      throw Exception('Model inference failed: $e');
    }
  }

  /// Get model output
  /// @return Model output as List<List<double>>
  List<List<double>> getModelOutput() {
    if (_isDisposed) {
      throw StateError('TFLite wrapper has been disposed');
    }

    try {
      // Get output tensor
      final outputTensor = _interpreter.getOutputTensors();
      if (outputTensor.isEmpty) {
        return [];
      }

      // Convert to List<List<double>>
      final output = outputTensor.first.data as List<List<double>>;
      return output;
    } catch (e) {
      throw Exception('Failed to get model output: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    if (!_isDisposed) {
      _interpreter.close();
      _isDisposed = true;
    }
  }
}

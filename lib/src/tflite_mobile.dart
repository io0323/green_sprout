import 'package:tflite_flutter/tflite_flutter.dart';
import 'tflite_interface.dart';

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
  static Future<TfliteWrapper?> create() async {
    try {
      final interpreter =
          await Interpreter.fromAsset('assets/models/tea_model.tflite');
      return TfliteWrapper._(interpreter);
    } catch (e) {
      return null; // Model loading failed
    }
  }

  /// Get input tensor information
  TensorInfo getInputTensor(int index) {
    if (_isDisposed) {
      throw StateError('TFLite wrapper has been disposed');
    }

    try {
      final tensor = _interpreter.getInputTensors()[index];
      return TensorInfo(shape: tensor.shape, dtype: tensor.type.toString());
    } catch (e) {
      throw Exception('Failed to get input tensor: $e');
    }
  }

  /// Get output tensor information
  TensorInfo getOutputTensor(int index) {
    if (_isDisposed) {
      throw StateError('TFLite wrapper has been disposed');
    }

    try {
      final tensor = _interpreter.getOutputTensors()[index];
      return TensorInfo(shape: tensor.shape, dtype: tensor.type.toString());
    } catch (e) {
      throw Exception('Failed to get output tensor: $e');
    }
  }

  /// Run model inference
  void run(Object input, Object output) {
    if (_isDisposed) {
      throw StateError('TFLite wrapper has been disposed');
    }

    try {
      _interpreter.run(input, output);
    } catch (e) {
      throw Exception('Model inference failed: $e');
    }
  }

  /// Run model inference with input data (convenience method)
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

  /// Get model output (convenience method)
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

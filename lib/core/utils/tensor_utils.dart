/// Utility functions for tensor operations
class TensorUtils {
  /// Converts flat List<T> into nested lists by shape
  static dynamic reshape(List data, List<int> shape) {
    if (shape.isEmpty) return data;
    if (shape.length == 1) {
      // ensure correct length
      if (data.length != shape[0]) {
        throw ArgumentError(
            'Data length ${data.length} does not match shape[0] ${shape[0]}');
      }
      return data;
    }
    final int outer = shape[0];
    final int innerSize = shape.sublist(1).fold(1, (a, b) => a * b);
    final List result = <dynamic>[];
    for (int i = 0; i < outer; i++) {
      final int start = i * innerSize;
      final int end = start + innerSize;
      result.add(reshape(data.sublist(start, end), shape.sublist(1)));
    }
    return result;
  }
}

// TFLite platform abstraction interface
// Uses conditional imports to provide native implementation or web stub

// Conditional export: use native implementation when FFI is available, stub for web
export 'tflite_stub_web.dart' if (dart.library.ffi) 'tflite_native.dart';

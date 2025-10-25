/// TFLite platform abstraction interface
/// Uses conditional imports to provide mobile implementation or web stub
export 'tflite_stub.dart' // default for web
    if (dart.library.io) 'tflite_mobile.dart';

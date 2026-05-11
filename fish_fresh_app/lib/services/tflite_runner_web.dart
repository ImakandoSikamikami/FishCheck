import 'dart:typed_data';

/// Web stub — tflite_flutter is not available on web.
class TfliteRunner {
  static Future<bool> loadFromAsset(String modelPath) async => false;
  static bool get isLoaded => false;
  static Future<List<double>?> classify(Uint8List bytes) async => null;
  static void close() {}
}

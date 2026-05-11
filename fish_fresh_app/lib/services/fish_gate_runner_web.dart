import 'dart:typed_data';

// Web stub — tflite_flutter is not available on web.
class FishGateRunner {
  static Future<bool> loadFromAsset(String modelPath) async => false;
  static bool get isLoaded => false;
  static Future<bool> isFish(Uint8List bytes) async => true;
  static void close() {}
}

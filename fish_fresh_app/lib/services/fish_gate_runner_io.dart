import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Mobile/desktop fish-presence gate using quantized MobileNetV2 (ImageNet 1001-class).
/// Imported via conditional import — never used on web.
class FishGateRunner {
  static Interpreter? _interpreter;

  // ImageNet 1001-class indices (background = 0) that represent fish / aquatic animals.
  // Used to decide "is there a fish in this image?"
  static const Set<int> _fishIndices = {
    1,   // tench (freshwater fish — close relative of tilapia habitat)
    2,   // goldfish
    3,   // great white shark
    4,   // tiger shark
    5,   // hammerhead shark
    6,   // electric ray
    7,   // stingray
    387, // barracouta, snoek
    388, // eel
    389, // coho salmon
    390, // rock beauty (reef fish)
    391, // anemone fish
    392, // sturgeon
    393, // gar
    394, // lionfish
    395, // puffer
  };

  // Minimum uint8 score (0–255) any fish class must reach to accept the image.
  // 30/255 ≈ 12% — low enough for unusual fish species, high enough to block people/objects.
  static const int _fishThreshold = 30;

  static Future<bool> loadFromAsset(String modelPath) async {
    try {
      _interpreter?.close();
      _interpreter = await Interpreter.fromAsset(modelPath);
      return true;
    } catch (e) {
      _interpreter = null;
      return false;
    }
  }

  static bool get isLoaded => _interpreter != null;

  /// Returns true when the image likely contains a fish.
  /// Returns true (allow-through) on any inference error so we never
  /// accidentally block a valid scan due to a model issue.
  static Future<bool> isFish(Uint8List bytes) async {
    if (_interpreter == null) return true;
    try {
      // Decode to 224 × 224
      final codec = await ui.instantiateImageCodec(
          bytes, targetWidth: 224, targetHeight: 224);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (byteData == null) return true;

      final rgba = byteData.buffer.asUint8List();

      // Build [1][224][224][3] uint8 input — raw pixel values, no normalisation
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(224, (x) {
            final src = (y * 224 + x) * 4;
            return [rgba[src], rgba[src + 1], rgba[src + 2]];
          }),
        ),
      );

      // Output: [1][1001] uint8 — higher value = higher probability
      final output = [List<int>.filled(1001, 0)];
      _interpreter!.run(input, output);

      final scores = output[0];

      // Accept if any fish-related class exceeds the threshold
      for (final idx in _fishIndices) {
        if (idx < scores.length && scores[idx] > _fishThreshold) return true;
      }
      return false;
    } catch (_) {
      return true; // allow-through on unexpected error
    }
  }

  static void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}

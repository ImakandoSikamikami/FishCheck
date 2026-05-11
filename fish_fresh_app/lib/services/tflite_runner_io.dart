import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Mobile/desktop TFLite runner. Imported via conditional import — never used on web.
class TfliteRunner {
  static Interpreter? _interpreter;

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

  /// Decodes [bytes] to 224×224, runs freshness inference.
  /// Returns [fresh_prob, acceptable_prob, spoiled_prob] normalised to sum = 1,
  /// or null if inference fails for any reason.
  static Future<List<double>?> classify(Uint8List bytes) async {
    if (_interpreter == null) return null;
    try {
      final codec = await ui.instantiateImageCodec(
          bytes, targetWidth: 224, targetHeight: 224);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (byteData == null) return null;

      final rgba = byteData.buffer.asUint8List();

      // Build [1][224][224][3] float input normalised to [0, 1]
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(224, (x) {
            final src = (y * 224 + x) * 4;
            return <double>[
              rgba[src] / 255.0,
              rgba[src + 1] / 255.0,
              rgba[src + 2] / 255.0,
            ];
          }),
        ),
      );

      final output = [List<double>.filled(3, 0.0)];
      _interpreter!.run(input, output);

      final raw = List<double>.from(output[0] as List);
      final sum = raw.fold(0.0, (a, b) => a + b);
      if (sum <= 0) return null;
      return raw.map((p) => p / sum).toList();
    } catch (_) {
      return null;
    }
  }

  static void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}

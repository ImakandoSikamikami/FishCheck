import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

enum ImageSourceType { camera, gallery }

/// Result from picking and processing an image.
class ProcessedImage {
  /// Compressed bytes ready to send for analysis.
  final Uint8List bytes;

  /// MIME type: image/jpeg, image/png, image/webp.
  final String mediaType;

  /// Original filename (for display only).
  final String? filename;

  /// File size in KB after compression.
  final int sizeKb;

  const ProcessedImage({
    required this.bytes,
    required this.mediaType,
    this.filename,
    required this.sizeKb,
  });
}

/// Handles picking images from camera or gallery on all platforms,
/// converting any format to JPEG, resizing, and compressing.
class ImagePipeline {
  static final _picker = ImagePicker();

  // Max dimension for the longer side before sending to analysis
  static const int _maxDimension = 1200;

  // Target max size in KB
  static const int _targetKb = 700;

  /// Returns true if this platform has a hardware camera.
  static bool get hasCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Returns true if running on desktop (Windows/macOS/Linux).
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Pick an image from [source] and run it through the processing pipeline.
  /// Returns null if the user cancelled or permission was denied.
  /// Pass [context] to show a SnackBar when permission is denied.
  static Future<ProcessedImage?> pick(
    ImageSourceType source, {
    BuildContext? context,
  }) async {
    if (!kIsWeb && !isDesktop) {
      final permission = source == ImageSourceType.camera
          ? Permission.camera
          : Permission.photos;
      final status = await permission.status;
      if (status.isDenied) {
        final result = await permission.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          _showPermissionDenied(context);
          return null;
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionDenied(context);
        return null;
      }
    }

    try {
      if (source == ImageSourceType.camera && !isDesktop) {
        return await _pickFromCamera();
      }
      if (isDesktop || kIsWeb) {
        return await _pickFromFileSystem();
      }
      return await _pickFromGallery();
    } on Exception catch (e) {
      // image_picker throws PlatformException when the user permanently denies
      // permission after the native prompt (e.g. iOS Settings revoked access).
      final msg = e.toString();
      if (msg.contains('camera_access_denied') ||
          msg.contains('photo_access_denied') ||
          msg.contains('access_denied')) {
        _showPermissionDenied(context);
        return null;
      }
      debugPrint('ImagePipeline.pick error: $e');
      rethrow;
    }
  }

  static void _showPermissionDenied(BuildContext? context) {
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Camera/gallery permission denied. Please enable it in Settings.',
        ),
      ),
    );
  }

  // ─── Camera ────────────────────────────────────────────────────────────────

  static Future<ProcessedImage?> _pickFromCamera() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
    );
    if (xfile == null) return null;
    final raw = await xfile.readAsBytes();
    return _process(raw, xfile.name);
  }

  // ─── Mobile gallery ────────────────────────────────────────────────────────

  static Future<ProcessedImage?> _pickFromGallery() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
    );
    if (xfile == null) return null;
    final raw = await xfile.readAsBytes();
    return _process(raw, xfile.name);
  }

  // ─── Desktop / Web file picker ─────────────────────────────────────────────

  static Future<ProcessedImage?> _pickFromFileSystem() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // Accept every common image format
      allowedExtensions: [
        'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif',
        'bmp', 'tiff', 'tif', 'gif',
      ],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;
    return _process(bytes, file.name);
  }

  // ─── Processing pipeline ───────────────────────────────────────────────────

  static Future<ProcessedImage?> _process(Uint8List raw, String? filename) async {
    // Determine input format
    final ext = (filename ?? '').split('.').last.toLowerCase();

    Uint8List processed;

    // flutter_image_compress handles HEIC, JPEG, PNG, WEBP, BMP on mobile.
    // On web / desktop it's not available so we fall back to raw bytes.
    if (!kIsWeb && !isDesktop) {
      try {
        final compressed = await FlutterImageCompress.compressWithList(
          raw,
          minWidth: _maxDimension,
          minHeight: _maxDimension,
          quality: 85,
          format: CompressFormat.jpeg,
          // Auto-rotate based on EXIF
          autoCorrectionAngle: true,
        );
        processed = Uint8List.fromList(compressed);
      } catch (_) {
        // Fallback: use raw bytes if compression fails
        processed = raw;
      }
    } else {
      // Web / desktop: send bytes as-is, the API accepts PNG/JPEG/WEBP/GIF
      processed = raw;
    }

    // Warn in debug if still over target
    final sizeKb = processed.lengthInBytes ~/ 1024;
    if (sizeKb > _targetKb) {
      debugPrint('ImagePipeline: image is ${sizeKb}KB (target ${_targetKb}KB)');
    }

    // Determine output MIME type
    // After compression we output JPEG; on web/desktop preserve original format
    final mediaType = (!kIsWeb && !isDesktop)
        ? 'image/jpeg'
        : _mimeFromExt(ext);

    return ProcessedImage(
      bytes: processed,
      mediaType: mediaType,
      filename: filename,
      sizeKb: sizeKb,
    );
  }

  static String _mimeFromExt(String ext) {
    switch (ext) {
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      case 'gif': return 'image/gif';
      case 'heic':
      case 'heif': return 'image/heic';
      default: return 'image/jpeg';
    }
  }
}

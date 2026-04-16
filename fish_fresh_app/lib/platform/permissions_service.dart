import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResult { granted, denied, permanentlyDenied }

class PermissionsService {
  /// Request camera permission. Returns result.
  static Future<PermissionResult> requestCamera() async {
    if (kIsWeb || _isDesktop) return PermissionResult.granted;
    final status = await Permission.camera.request();
    return _map(status);
  }

  /// Request photo library / storage permission.
  static Future<PermissionResult> requestGallery() async {
    if (kIsWeb || _isDesktop) return PermissionResult.granted;
    final perm = defaultTargetPlatform == TargetPlatform.iOS
        ? Permission.photos
        : Permission.storage;
    final status = await perm.request();
    return _map(status);
  }

  static bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  static PermissionResult _map(PermissionStatus s) {
    if (s.isGranted || s.isLimited) return PermissionResult.granted;
    if (s.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  /// Show a dialog explaining why permission is needed and offer to open settings.
  static Future<void> showDeniedDialog(
    BuildContext context, {
    required String permission,
    required String reason,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$permission access needed'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }
}

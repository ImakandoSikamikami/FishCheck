import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialised = false;

  static const _scanReminderChannel = 'scan_reminders';
  static const _queueChannel = 'offline_queue';
  static const _generalChannel = 'general';
  static const _queueNotifId = 1;

  static Future<void> init() async {
    if (_initialised) return;
    if (kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _scanReminderChannel, 'Scan reminders',
          description: 'Reminds you to re-check fish stock',
          importance: Importance.defaultImportance,
        ));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _queueChannel, 'Offline queue',
          description: 'Alerts when offline scans are ready',
          importance: Importance.high,
        ));

    _initialised = true;
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return false;
  }

  static Future<void> showQueueReadyNotification(int count) async {
    if (!_initialised) return;
    await _plugin.show(
      _queueNotifId,
      'FishCheck ZM — Scans ready',
      '$count offline scan${count > 1 ? "s" : ""} ready to analyse.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _queueChannel, 'Offline queue',
          channelDescription: 'Offline queue alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(badgeNumber: 1),
      ),
      payload: 'queue_ready',
    );
  }

  static Future<void> showGeneral({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialised) return;
    await _plugin.show(
      0, title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _generalChannel, 'General',
          channelDescription: 'General notifications',
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  static Future<void> cancelAll() async {
    if (!_initialised) return;
    await _plugin.cancelAll();
  }

  static void _onTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }
}

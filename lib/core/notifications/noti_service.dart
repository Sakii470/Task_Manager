import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class NotiService {
  NotiService._internal();
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  static const String _channelId = 'daily_channel_id';
  static const String _channelName = 'Daily Notifications';
  static const String _channelDesc = 'Daily notification channel';

  Future<void> initNotification() async {
    if (_isInitialized) return;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await permission_handler.Permission.notification.status;
        if (!status.isGranted) {
          await permission_handler.Permission.notification.request();
        }
      }
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: initSettingsAndroid, iOS: initSettingsIOS);
    await _plugin.initialize(initSettings);

    // Create Android channel explicitly (no-op on non-Android)
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    _isInitialized = true;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    if (!_isInitialized) await initNotification();
    try {
      await _plugin.show(id, title, body, _notificationDetails());
    } catch (e, s) {
      debugPrint('showNotification error: $e');
      debugPrint('$s');
      rethrow;
    }
  }
}

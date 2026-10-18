import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local (on-device) notifications. No server, no push service — the app
/// shows notifications by itself, which is exactly what a demo needs.
class Notify {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// Call once from main() after the bindings are initialised.
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _ready = true;
  }

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Asks the user for notification permission (Android 13+ shows a system
  /// dialog; older versions grant it automatically). Returns whether it is on.
  static Future<bool> requestPermission() async {
    final a = _android;
    if (a == null) return false;
    final granted = await a.requestNotificationsPermission();
    return granted ?? true;
  }

  static Future<void> show(String title, String body, {int id = 0}) async {
    if (!_ready) return;
    const android = AndroidNotificationDetails(
      'clc_default',
      'CLC Notifications',
      channelDescription: 'General updates from CLC Barmer',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _plugin.show(id, title, body, details);
  }

  /// The one welcome notification used to test that notifications work.
  static Future<void> welcome() =>
      show('Welcome to CLC Barmer', 'Your learning journey starts here.', id: 1001);
}

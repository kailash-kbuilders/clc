import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local on-device storage (a simple mobile database on top of
/// SharedPreferences). Everything the app needs to remember between
/// launches lives here: completed lessons, read notices, test results
/// and the notification settings.
class Store {
  static SharedPreferences? _p;

  /// Call once from main() before runApp().
  static Future<void> init() async {
    _p ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _prefs {
    final p = _p;
    if (p == null) {
      throw StateError('Store.init() must be awaited before use.');
    }
    return p;
  }

  // ── Completed lessons ──
  static Set<String> readDone() => (_prefs.getStringList('done') ?? const []).toSet();

  static Future<void> saveDone(Set<String> v) => _prefs.setStringList('done', v.toList());

  // ── Read notices ──
  static Set<int> readRead() =>
      (_prefs.getStringList('read') ?? const []).map(int.parse).toSet();

  static Future<void> saveRead(Set<int> v) =>
      _prefs.setStringList('read', v.map((e) => e.toString()).toList());

  // ── Test results ──
  static List<Map<String, dynamic>> readResults() => (_prefs.getStringList('results') ?? const [])
      .map((s) => jsonDecode(s) as Map<String, dynamic>)
      .toList();

  static Future<void> saveResults(List<Map<String, dynamic>> v) =>
      _prefs.setStringList('results', v.map(jsonEncode).toList());

  // ── Settings ──
  static bool get notifEnabled => _prefs.getBool('notif') ?? true;

  static Future<void> setNotif(bool v) => _prefs.setBool('notif', v);

  static bool get remindersEnabled => _prefs.getBool('reminders') ?? true;

  static Future<void> setReminders(bool v) => _prefs.setBool('reminders', v);
}

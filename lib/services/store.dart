import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local on-device storage (a simple mobile database on top of
/// SharedPreferences). Everything the app needs to remember between
/// launches lives here: completed lessons, read notices, test results
/// and the notification settings.
///
/// Nothing in here ever throws — if storage is unavailable the app still
/// runs, it just won't remember things.
class Store {
  static SharedPreferences? _p;

  /// Call once from main() before runApp(). Never throws.
  static Future<void> init() async {
    try {
      _p = await SharedPreferences.getInstance();
    } catch (_) {
      _p = null;
    }
  }

  // ── Completed lessons ──
  static Set<String> readDone() => (_p?.getStringList('done') ?? const []).toSet();

  static Future<void> saveDone(Set<String> v) async {
    await _p?.setStringList('done', v.toList());
  }

  // ── Read notices ──
  static Set<int> readRead() =>
      (_p?.getStringList('read') ?? const []).map(int.parse).toSet();

  static Future<void> saveRead(Set<int> v) async {
    await _p?.setStringList('read', v.map((e) => e.toString()).toList());
  }

  // ── Test results ──
  static List<Map<String, dynamic>> readResults() =>
      (_p?.getStringList('results') ?? const [])
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();

  static Future<void> saveResults(List<Map<String, dynamic>> v) async {
    await _p?.setStringList('results', v.map(jsonEncode).toList());
  }

  // ── Settings ──
  static bool get notifEnabled => _p?.getBool('notif') ?? true;

  static Future<void> setNotif(bool v) async {
    await _p?.setBool('notif', v);
  }

  static bool get remindersEnabled => _p?.getBool('reminders') ?? true;

  static Future<void> setReminders(bool v) async {
    await _p?.setBool('reminders', v);
  }
}

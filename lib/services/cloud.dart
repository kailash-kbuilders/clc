import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project for CLC Barmer (ap-south-1 / Mumbai).
///
/// The publishable key is safe to ship inside the app. Secrets are never
/// kept here — anything sensitive belongs in a server/edge function.
const String supabaseUrl = 'https://tpudielhybpuvclbxghh.supabase.co';
const String supabaseAnonKey = 'sb_publishable_IuMvqlN3uM_ouECkIpTI-g_4Hqa3Z--';

/// Cloud account + data. Every call fails quietly, so the app keeps working
/// even if the cloud is unreachable.
class Cloud {
  static bool ready = false;

  static Future<void> init() async {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      ready = true;
    } catch (_) {
      ready = false;
    }
  }

  static SupabaseClient? get _c => ready ? Supabase.instance.client : null;

  /// Sends an OTP to a +91 number. Returns null on success, else a message.
  static Future<String?> sendOtp(String phoneE164) async {
    final c = _c;
    if (c == null) return 'Cloud not available';
    try {
      await c.auth.signInWithOtp(phone: phoneE164);
      return null;
    } catch (e) {
      return _friendly(e);
    }
  }

  /// Verifies the OTP. Returns null on success, else a message.
  static Future<String?> verifyOtp(String phoneE164, String token) async {
    final c = _c;
    if (c == null) return 'Cloud not available';
    try {
      await c.auth.verifyOTP(type: OtpType.sms, phone: phoneE164, token: token);
      return null;
    } catch (e) {
      return _friendly(e);
    }
  }

  /// The signed-in user's profile row, or null when there isn't one yet.
  static Future<Map<String, dynamic>?> myProfile() async {
    final c = _c;
    final u = c?.auth.currentUser;
    if (c == null || u == null) return null;
    try {
      final row = await c.from('profiles').select().eq('id', u.id).maybeSingle();
      return row;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveProfile(String name, String cls) async {
    final c = _c;
    final u = c?.auth.currentUser;
    if (c == null || u == null) return;
    try {
      await c.from('profiles').upsert({
        'id': u.id,
        'phone': u.phone,
        'name': name,
        'class': cls,
      });
    } catch (_) {}
  }

  /// Course ids this account has bought (works on any phone).
  static Future<Set<String>> myPurchases() async {
    final c = _c;
    final u = c?.auth.currentUser;
    if (c == null || u == null) return {};
    try {
      final rows = await c.from('purchases').select('course_id').eq('user_id', u.id);
      return (rows as List).map((r) => r['course_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> addPurchase(String courseId) async {
    final c = _c;
    final u = c?.auth.currentUser;
    if (c == null || u == null) return;
    try {
      await c.from('purchases').upsert({'user_id': u.id, 'course_id': courseId});
    } catch (_) {}
  }

  static Future<void> signOut() async {
    try {
      await _c?.auth.signOut();
    } catch (_) {}
  }

  static String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('provider') || s.contains('sms') || s.contains('SMS')) {
      return 'SMS is not set up in Supabase yet.';
    }
    if (s.contains('rate') || s.contains('Too many')) return 'Too many attempts. Try again in a minute.';
    if (s.contains('Invalid') || s.contains('invalid')) return 'Incorrect OTP. Please try again.';
    return s.length > 150 ? s.substring(0, 150) : s;
  }
}

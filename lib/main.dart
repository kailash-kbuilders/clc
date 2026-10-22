import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';
import 'courses.dart';
import 'tests.dart';
import 'more.dart';
import 'library.dart';
import 'services/store.dart';
import 'services/notify.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Local storage first, so saved progress/settings are ready before the UI.
  // Wrapped so a storage problem can never stop the app from launching.
  try {
    await Store.init();
    AppState.i.hydrate();
  } catch (_) {}
  runApp(const ClcApp());
}

class ClcApp extends StatelessWidget {
  const ClcApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CLC Barmer',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(),
      );
}

// ───────── Splash ─────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        // Already logged in -> straight to Home, no login every time.
        pageBuilder: (_, __, ___) => Store.isLoggedIn ? const Shell() : const AuthScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kNavy, Color(0xFF2A31B8)])),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .6, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const Logo(size: 120)),
            ),
            const SizedBox(height: 24),
            const Text('CLC Barmer',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Learn • Practice • Achieve',
                style: TextStyle(color: Colors.white.withOpacity(.8), letterSpacing: 1.2)),
          ]),
        ),
      );
}

// ───────── Login / Signup (mobile + OTP, one flow) ─────────
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;

  // Demo OTP — a real OTP needs an SMS gateway (see the note in the app).
  static const _demoOtp = '123456';

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(_phone.text.trim())) {
      snack(context, 'Enter a valid 10-digit mobile number.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _otpSent = true);
    snack(context, 'Demo OTP sent: $_demoOtp');
  }

  Future<void> _verify() async {
    if (_otp.text.trim() != _demoOtp) {
      snack(context, 'Incorrect OTP. In this demo use $_demoOtp.');
      return;
    }
    setState(() => _busy = true);
    AppState.i.setPhone(_phone.text.trim());
    await Store.setLoggedIn(true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    // Existing account on this phone -> straight to Home with saved data.
    // New account -> ask name and class first.
    if (Store.hasProfile) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 28, 24, 32),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kNavy, Color(0xFF2A31B8)]),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
              child: Column(children: [
                Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Logo(size: 84)),
                const SizedBox(height: 16),
                const Text('Welcome to CLC Barmer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(_otpSent ? 'Enter the OTP to continue' : 'Login or create your account',
                    style: TextStyle(color: Colors.white.withOpacity(.85))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                TextField(
                  controller: _phone,
                  enabled: !_otpSent,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                      labelText: 'Mobile number',
                      counterText: '',
                      prefixIcon: const Icon(Icons.phone_android),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                        labelText: 'OTP',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  ),
                  const SizedBox(height: 6),
                  Text('Demo OTP: $_demoOtp  •  SMS gateway not connected yet', style: mS),
                ],
                const SizedBox(height: 18),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: _busy ? null : (_otpSent ? _verify : _sendOtp),
                        child: Text(_otpSent ? 'Verify & Continue' : 'Send OTP'))),
                if (_otpSent)
                  TextButton(
                      onPressed: _busy ? null : () => setState(() => _otpSent = false),
                      child: const Text('Change number')),
                const SizedBox(height: 10),
                const Text('New here? Same flow — continue and we will ask your name and class.',
                    textAlign: TextAlign.center, style: mS),
              ]),
            ),
          ]),
        ),
      );
}

// ───────── New account: name + class ─────────
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  String _cls = 'Class 6';
  static const _classes = ['Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      snack(context, 'Please enter your name.');
      return;
    }
    AppState.i.setProfile(name, _cls);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create your account')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Tell us about you',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
          const SizedBox(height: 4),
          const Text('Saved on your phone only.', style: mS),
          const SizedBox(height: 22),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: 'Full name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _cls,
            decoration: InputDecoration(
                labelText: 'Class',
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            items: _classes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _cls = v ?? _cls),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _continue, child: const Text('Continue')),
        ]),
      );
}

// ───────── Shell (bottom nav) ─────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    // Ask for notification permission only after the user reaches Home
    // (i.e. after login / explore) — never on the splash or login screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _askNotifications());
  }

  Future<void> _askNotifications() async {
    // Only the very first time the user reaches Home: ask permission and
    // show one welcome notification. Never again after that.
    if (Store.notifAsked) return;
    try {
      await Notify.init();
      final granted = await Notify.requestPermission();
      if (granted) await Notify.welcome();
      await Store.setNotifAsked(true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: _i, children: [
            HomeScreen(go: (n) => setState(() => _i = n)),
            const CoursesScreen(),
            const TestsScreen(),
            const StudyScreen(),
            const ProfileScreen(),
          ]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (n) => setState(() => _i = n),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Courses'),
            NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: 'Tests'),
            NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Material'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
}

// ───────── Home ─────────
class HomeScreen extends StatelessWidget {
  final void Function(int) go;
  const HomeScreen({super.key, required this.go});

  Widget _practice(String t, String s, IconData i, List<Color> g, VoidCallback f) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(i, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text(s, style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 11.5)),
            ]),
          ),
        ),
      );

  Widget _event(IconData i, String t, String when) => ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: kNavy.withOpacity(.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(i, color: kNavy)),
        title: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        subtitle: Text('$when • schedule', style: mS),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          const Logo(size: 42),
          const SizedBox(width: 10),
          Expanded(
              child: ListenableBuilder(
            listenable: AppState.i,
            builder: (_, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hi, ${AppState.i.userName}!',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: hS),
              const Text('Ready to learn something new?', style: mS),
            ]),
          )),
          ListenableBuilder(
            listenable: AppState.i,
            builder: (_, __) => IconButton(
              onPressed: () => push(context, const NotificationsScreen()),
              icon: Badge(
                  isLabelVisible: AppState.i.unread > 0,
                  label: Text('${AppState.i.unread}'),
                  child: const Icon(Icons.notifications_none, size: 28)),
            ),
          ),
          GestureDetector(
            onTap: () => go(4),
            child: const CircleAvatar(
                radius: 18,
                backgroundColor: kNavy,
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ),
        ]),
      ),

      // ── Quick actions, up front like PW ──
      QuickActions(items: [
        QuickAction(Icons.school, 'My Courses', kNavy, () => go(1)),
        QuickAction(Icons.quiz, 'Online Tests', const Color(0xFFE65100), () => go(2)),
        QuickAction(Icons.download, 'Downloads', kGreen, () => push(context, const DownloadsScreen())),
        QuickAction(Icons.help_outline, 'Ask a Question', const Color(0xFF00838F), () => push(context, const AskScreen())),
      ]),

      BannerCarousel(items: banners, onCta: go),

      // Continue learning
      const SectionTitle('Continue Learning'),
      ListenableBuilder(
        listenable: AppState.i,
        builder: (_, __) {
          final c = courses[0];
          final s = c.subjects.first;
          final t = s.topics.first;
          final k = t.classes.first;
          final p = AppState.i.progressOf(c);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: cardDeco(),
            child: Column(children: [
              Row(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(c.image, width: 56, height: 56, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, style: mS),
                  const SizedBox(height: 2),
                  Text(t.title, style: tS),
                ])),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: AppProgress(p)),
                const SizedBox(width: 10),
                Text('${(p * 100).round()}%', style: tS),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: () => push(context,
                          ClassPlayerScreen(course: c, subject: s, topic: t, item: k)),
                      child: const Text('Continue Learning'))),
            ]),
          );
        },
      ),

      // Explore courses
      const SectionTitle('Explore Courses'),
      SizedBox(
        height: 292,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 4),
          itemCount: courses.length,
          itemBuilder: (_, n) =>
              CourseCard(courses[n], onTap: () => push(context, CourseDetailScreen(course: courses[n]))),
        ),
      ),

      // Practice zone
      const SectionTitle('Practice Zone'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _practice('Question Paper', 'Attempt the latest JNV Navodaya paper.', Icons.local_fire_department,
                const [Color(0xFFE65100), Color(0xFFFFA726)], () => push(context, PaperScreen(paper: papers[0]))),
            const SizedBox(width: 12),
            _practice('Mock Tests', 'Check your preparation with sample tests.', Icons.timer,
                const [Color(0xFF14196B), Color(0xFF3A42D4)], () => go(2)),
          ]),
        ),
      ),

      // Upcoming
      const SectionTitle('Upcoming Activity'),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: cardDeco(),
        child: Column(children: [
          _event(Icons.psychology_alt, 'Mental Ability Practice Test', 'Tomorrow, 10:00 AM'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _event(Icons.calculate, 'Mathematics Revision', 'Saturday, 4:00 PM'),
        ]),
      ),

      // Motivation
      Container(
        margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFFFFF3D6), Color(0xFFFFE0A3)])),
        child: const Row(children: [
          Icon(Icons.format_quote, size: 34, color: Color(0xFF9A5B00)),
          SizedBox(width: 10),
          Expanded(
              child: Text('Small steps every day lead to big results.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF5C3A00)))),
        ]),
      ),
      const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(child: Text('CLC Barmer', style: mS))),
    ]);
  }
}

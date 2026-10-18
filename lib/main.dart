import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';
import 'courses.dart';
import 'tests.dart';
import 'more.dart';
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
    // Notification setup runs after the first frame and can never block
    // navigation away from the splash screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupNotifications());
    Future.delayed(const Duration(milliseconds: 2200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child)));
  }

  /// On every app open: ask for notification permission, and if the user
  /// has notifications enabled, show the welcome notification. Any problem
  /// here is ignored — notifications are optional and never block startup.
  Future<void> _setupNotifications() async {
    try {
      await Notify.init();
      final granted = await Notify.requestPermission();
      if (granted && Store.notifEnabled) {
        await Notify.welcome();
      }
    } catch (_) {}
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

// ───────── Login ─────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  void _enter() => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));

  @override
  void dispose() {
    _phone.dispose();
    _pass.dispose();
    super.dispose();
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
                Text('Your learning journey starts here.',
                    style: TextStyle(color: Colors.white.withOpacity(.85))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _key,
                child: Column(children: [
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                        labelText: 'Mobile number',
                        counterText: '',
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                    validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v ?? '')
                        ? null
                        : 'Enter a valid 10-digit mobile number',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hide = !_hide)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                    validator: (v) =>
                        (v ?? '').length >= 6 ? null : 'Password must be at least 6 characters',
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () => snack(context, 'Demo only — password reset is simulated.'),
                          child: const Text('Forgot password?'))),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                          onPressed: () {
                            if (_key.currentState!.validate()) _enter();
                          },
                          child: const Text('Login'))),
                  const SizedBox(height: 12),
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                          onPressed: _enter,
                          icon: const Icon(Icons.explore),
                          label: const Text('Explore App'))),
                ]),
              ),
            ),
          ]),
        ),
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
          const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good morning, Aarav!', maxLines: 1, overflow: TextOverflow.ellipsis, style: hS),
            Text('Ready to learn something new?', style: mS),
          ])),
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
        QuickAction(Icons.description, 'Study Notes', kGreen, () => go(3)),
        QuickAction(Icons.bar_chart, 'Results', const Color(0xFF6A3BD6), () => push(context, const ResultsScreen())),
        QuickAction(Icons.campaign, 'Announcements', const Color(0xFFC62828), () => push(context, const NotificationsScreen())),
        QuickAction(Icons.help_outline, 'Ask a Question', const Color(0xFF00838F), () => push(context, const AskScreen())),
      ]),

      BannerCarousel(items: banners, onCta: go),

      // Continue learning
      const SectionTitle('Continue Learning'),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: cardDeco(),
        child: Column(children: [
          Row(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: kNavy.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.psychology, color: kNavy, size: 28)),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Navodaya Class 6 Foundation', style: mS),
              SizedBox(height: 2),
              Text('Introduction to Mental Ability', style: tS),
            ])),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            const Expanded(child: AppProgress(.65)),
            const SizedBox(width: 10),
            const Text('65%', style: tS),
          ]),
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () => push(context, LessonScreen(course: courses[0], index: 2)),
                  child: const Text('Continue Learning'))),
        ]),
      ),

      // Explore courses
      const SectionTitle('Explore Courses'),
      SizedBox(
        height: 252,
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
            _practice('Daily Practice', 'Build your habit with short practice sessions.', Icons.local_fire_department,
                const [Color(0xFFE65100), Color(0xFFFFA726)], () => push(context, TestInstructionsScreen(t: tests[0]))),
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

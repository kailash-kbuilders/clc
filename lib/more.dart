import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';
import 'main.dart' show AuthScreen;
import 'services/store.dart';
import 'services/notify.dart';

// ───────── Study material ─────────
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});
  @override
  State<StudyScreen> createState() => _StudyState();
}

class _StudyState extends State<StudyScreen> {
  String _q = '';
  String _subject = 'All';
  final List<Note> _recent = [];
  static const _subjects = ['All', 'Reasoning', 'Maths', 'English', 'GK'];

  void _open(Note n) {
    _recent.remove(n);
    _recent.insert(0, n);
    push(context, NotePreviewScreen(note: n));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = notes
        .where((n) =>
            (_subject == 'All' || n.subject == _subject) &&
            n.title.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Study Material', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
      const Text('Demo content — no real CLC material uploaded', style: mS),
      const SizedBox(height: 12),
      TextField(
        onChanged: (v) => setState(() => _q = v),
        decoration: InputDecoration(
            hintText: 'Search notes',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 40,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final s in _subjects)
            Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                    label: Text(s), selected: _subject == s, onSelected: (_) => setState(() => _subject = s))),
        ]),
      ),
      if (_recent.isNotEmpty) ...[
        const SizedBox(height: 14),
        const Text('Recently viewed', style: hS),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final n in _recent)
              Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                      avatar: const Icon(Icons.history, size: 16),
                      label: Text(n.subject),
                      onPressed: () => _open(n))),
          ]),
        ),
      ],
      const SizedBox(height: 14),
      if (list.isEmpty)
        const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(children: [
              Icon(Icons.search_off, size: 54, color: kMuted),
              SizedBox(height: 8),
              Text('No material found', style: tS),
            ])),
      for (final n in list)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: cardDeco(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFD84315).withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.picture_as_pdf, color: Color(0xFFD84315))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: tS),
                const SizedBox(height: 4),
                Text('${n.subject} • ${n.module} • ${n.pages}', style: mS),
              ])),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const TagChip('DEMO CONTENT', kOrange),
              const Spacer(),
              IconButton(
                  onPressed: () => snack(context, 'Simulated download — no real file in demo.'),
                  icon: const Icon(Icons.download)),
              FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 38)),
                  onPressed: () => _open(n),
                  child: const Text('Open Notes')),
            ]),
          ]),
        ),
    ]);
  }
}

class NotePreviewScreen extends StatelessWidget {
  final Note note;
  const NotePreviewScreen({super.key, required this.note});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(note.subject)),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: kOrange.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
              child: const Text('SAMPLE PREVIEW — fictional content, not real CLC material.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9A5B00)))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDeco(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(note.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kNavy)),
              const Divider(height: 28),
              const Text('Key Idea', style: tS),
              const SizedBox(height: 6),
              const Text('Spot the rule first, then apply it. In a number series, check the difference or the multiplier between neighbouring terms.',
                  style: TextStyle(color: kMuted, height: 1.5)),
              const SizedBox(height: 16),
              const Text('Example', style: tS),
              const SizedBox(height: 6),
              const Text('2, 4, 6, 8, ?  →  each term adds 2, so the next term is 10.',
                  style: TextStyle(color: kMuted, height: 1.5)),
              const SizedBox(height: 16),
              const Text('Try it yourself', style: tS),
              const SizedBox(height: 6),
              const Text('5, 10, 15, 20, ?', style: TextStyle(color: kMuted, height: 1.5)),
            ]),
          ),
        ]),
      );
}

// ───────── Profile ─────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _row(BuildContext c, IconData i, String t, VoidCallback f) => ListTile(
      leading: Icon(i, color: kNavy), title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right), onTap: f);

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) => Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [kNavy, Color(0xFF3A42D4)])),
            child: Row(children: [
              CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                      AppState.i.userName.isEmpty ? 'S' : AppState.i.userName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kNavy))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppState.i.userName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(AppState.i.userClass.isEmpty ? 'Class not set' : AppState.i.userClass,
                    style: const TextStyle(color: Colors.white70)),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: cardDeco(),
          child: Column(children: [
            _row(context, Icons.bar_chart, 'Results & Performance', () => push(context, const ResultsScreen())),
            _row(context, Icons.notifications_none, 'Notifications', () => push(context, const NotificationsScreen())),
            _row(context, Icons.help_outline, 'Ask a Question', () => push(context, const AskScreen())),
            _row(context, Icons.settings_outlined, 'Settings', () => push(context, const SettingsScreen())),
            _row(context, Icons.support_agent, 'Help and Support', () => snack(context, 'Demo only — support is simulated.')),
            _row(context, Icons.info_outline, 'About CLC Barmer', () {
              showAboutDialog(
                  context: context,
                  applicationName: 'CLC Barmer',
                  applicationVersion: 'Demo 1.0',
                  children: const [
                    Text('Career Launcher Classes, Barmer — concept demo app. All content, names and scores are fictional placeholders.')
                  ]);
            }),
          ]),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()), (r) => false),
            icon: const Icon(Icons.logout),
            label: const Text('Logout')),
      ]);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  bool _notif = Store.notifEnabled;
  bool _reminders = Store.remindersEnabled;

  /// Turning notifications on asks for permission and, if granted, fires a
  /// welcome notification straight away so it can be tested instantly.
  Future<void> _toggleNotif(bool v) async {
    if (v) {
      final granted = await Notify.requestPermission();
      await Store.setNotif(v);
      if (!mounted) return;
      setState(() => _notif = v);
      if (granted) {
        await Notify.welcome();
      } else {
        snack(context, 'Permission denied — enable notifications in phone settings.');
      }
    } else {
      await Store.setNotif(false);
      if (!mounted) return;
      setState(() => _notif = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(children: [
          SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined, color: kNavy),
              title: const Text('Notifications'),
              subtitle: const Text('Get updates from CLC Barmer'),
              value: _notif,
              onChanged: _toggleNotif),
          SwitchListTile(
              secondary: const Icon(Icons.alarm, color: kNavy),
              title: const Text('Test reminders'),
              value: _reminders,
              onChanged: (v) async {
                await Store.setReminders(v);
                if (mounted) setState(() => _reminders = v);
              }),
          const Padding(padding: EdgeInsets.all(16), child: Text('Settings are saved on this device.', style: mS)),
        ]),
      );
}

// ───────── Results ─────────
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Widget _stat(String l, String v) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: cardDeco(),
          child: Column(children: [Text(v, style: hS), Text(l, style: mS)])));

  @override
  Widget build(BuildContext context) {
    const subj = {'Mental Ability': .85, 'Mathematics': .72, 'English': .64, 'General Knowledge': .70};
    return Scaffold(
      appBar: AppBar(title: const Text('Results & Performance')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kOrange.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
            child: const Text('Illustrative demo data — not actual student results.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9A5B00)))),
        const SizedBox(height: 14),
        Row(children: [
          _stat('Average', '72%'),
          const SizedBox(width: 10),
          _stat('Attempted', '4'),
          const SizedBox(width: 10),
          _stat('Best', '90%'),
        ]),
        const SectionTitle('Subject-wise'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDeco(),
          child: Column(children: [
            for (final e in subj.entries)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: [
                    SizedBox(width: 120, child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    Expanded(child: AppProgress(e.value, color: kNavy)),
                    const SizedBox(width: 8),
                    Text('${(e.value * 100).round()}%', style: mS),
                  ])),
          ]),
        ),
        const SectionTitle('Recent tests'),
        ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) => Container(
            decoration: cardDeco(),
            child: Column(children: [
              const ListTile(title: Text('Mental Ability — Set 1'), trailing: Text('90%', style: tS)),
              const ListTile(title: Text('Mathematics Basics'), trailing: Text('70%', style: tS)),
              for (final r in AppState.i.results.take(3))
                ListTile(
                    title: Text('${r.title} (just now)'),
                    trailing: Text('${(r.score / r.total * 100).round()}%', style: tS)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kNavy.withOpacity(.07), borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [
            Icon(Icons.lightbulb, color: kOrange),
            SizedBox(width: 12),
            Expanded(child: Text('Suggestion: spend 15 minutes daily on English grammar practice.', style: TextStyle(height: 1.3))),
          ]),
        ),
      ]),
    );
  }
}

// ───────── Notifications ─────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications'), actions: [
          TextButton(onPressed: AppState.i.readAll, child: const Text('Mark all read')),
        ]),
        body: ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
            const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Sample demo announcements', style: mS)),
            for (var n = 0; n < notices.length; n++)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: cardDeco(AppState.i.read.contains(n) ? Colors.white : const Color(0xFFEEF0FF)),
                child: ListTile(
                  onTap: () => AppState.i.markRead(n),
                  leading: Icon(AppState.i.read.contains(n) ? Icons.notifications_none : Icons.notifications_active,
                      color: AppState.i.read.contains(n) ? kMuted : kNavy),
                  title: Text(notices[n].title, style: tS),
                  subtitle: Text('${notices[n].body}\n${notices[n].time} • Demo', style: mS),
                  isThreeLine: true,
                  trailing: AppState.i.read.contains(n)
                      ? null
                      : const CircleAvatar(radius: 5, backgroundColor: kOrange),
                ),
              ),
          ]),
        ),
      );
}

// ───────── Ask a question ─────────
class AskScreen extends StatefulWidget {
  const AskScreen({super.key});
  @override
  State<AskScreen> createState() => _AskState();
}

class _AskState extends State<AskScreen> {
  String _subject = 'Mathematics';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ask a Question')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: InputDecoration(labelText: 'Subject', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            items: const ['Mathematics', 'Mental Ability', 'English', 'General Knowledge']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _subject = v ?? _subject),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            decoration: InputDecoration(labelText: 'Your question', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
              onPressed: () => snack(context, 'Attachments are a placeholder in this demo.'),
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach image (placeholder)')),
          const SizedBox(height: 14),
          FilledButton(
              onPressed: () {
                if (_ctrl.text.trim().isEmpty) {
                  snack(context, 'Please type your question first.');
                  return;
                }
                _ctrl.clear();
                snack(context, 'Saved locally in the demo only — not sent to the institute.');
              },
              child: const Text('Submit')),
          const SizedBox(height: 10),
          const Text('Demo: your question stays inside this app and is not sent to the real coaching institute.',
              textAlign: TextAlign.center, style: mS),
        ]),
      );
}

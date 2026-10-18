import 'dart:async';
import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';

// ───────── Tests centre ─────────
class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});
  @override
  State<TestsScreen> createState() => _TestsState();
}

class _TestsState extends State<TestsScreen> {
  bool _available = true;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Tests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
        const Text('All tests are sample / demo tests', style: mS),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => push(context, TestInstructionsScreen(t: tests[0])),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                    colors: [kNavy, Color(0xFF3A42D4)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Row(children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(8)),
                    child: const Text('FEATURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                const SizedBox(height: 10),
                const Text('Mental Ability Practice Test',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('10 questions • 10 minutes', style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 12)),
                const SizedBox(height: 12),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Start Now', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 12))),
              ])),
              const Icon(Icons.psychology, size: 80, color: Colors.white24),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Available')),
            ButtonSegment(value: false, label: Text('Completed')),
          ],
          selected: {_available},
          onSelectionChanged: (s) => setState(() => _available = s.first),
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) {
            if (_available) {
              return Column(children: [
                for (final t in tests)
                  _TestCard(
                      title: t.title,
                      line: '${t.subject} • ${t.q} questions • ${t.mins} min',
                      tag: 'SAMPLE',
                      color: kNavy,
                      onTap: () => push(context, TestInstructionsScreen(t: t))),
              ]);
            }
            final r = AppState.i.results;
            if (r.isEmpty) {
              return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Column(children: [
                    Icon(Icons.assignment_outlined, size: 54, color: kMuted),
                    SizedBox(height: 8),
                    Text('No completed tests yet', style: tS),
                    Text('Finish a sample test to see it here', style: mS),
                  ]));
            }
            return Column(children: [
              for (final x in r)
                _TestCard(
                    title: x.title,
                    line: 'Score ${x.score}/${x.total} (demo)',
                    tag: 'DONE',
                    color: kGreen,
                    onTap: () {}),
            ]);
          },
        ),
      ]);
}

class _TestCard extends StatelessWidget {
  final String title, line, tag;
  final Color color;
  final VoidCallback onTap;
  const _TestCard({required this.title, required this.line, required this.tag, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: cardDeco(),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          onTap: onTap,
          leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.quiz, color: color)),
          title: Text(title, style: tS),
          subtitle: Text(line, style: mS),
          trailing: TagChip(tag, color),
        ),
      );
}

// ───────── Instructions ─────────
class TestInstructionsScreen extends StatelessWidget {
  final TestInfo t;
  const TestInstructionsScreen({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    const rules = [
      'Each question has four options — choose one.',
      'Use Next / Previous or the number bubbles to move around.',
      'The timer runs locally; the test auto-submits at zero.',
      'You can submit any time after confirming.',
      'Scores are for demonstration only.',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Instructions')),
      bottomNavigationBar: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) => TestScreen(t: t))),
                  child: const Text('Start Test')))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(t.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 6),
        Row(children: [
          const TagChip('SAMPLE / DEMO TEST', kOrange),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _info(Icons.help_outline, '${questions.length}', 'Questions'),
          const SizedBox(width: 12),
          _info(Icons.timer_outlined, '${t.mins}', 'Minutes'),
        ]),
        const SizedBox(height: 20),
        const Text('Please read', style: hS),
        const SizedBox(height: 10),
        for (final r in rules)
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle, size: 18, color: kGreen),
                const SizedBox(width: 10),
                Expanded(child: Text(r, style: const TextStyle(color: kMuted, height: 1.3))),
              ])),
      ]),
    );
  }

  Widget _info(IconData i, String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDeco(),
          child: Row(children: [
            Icon(i, color: kNavy),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v, style: hS),
              Text(l, style: mS),
            ]),
          ]),
        ),
      );
}

// ───────── MCQ test ─────────
class TestScreen extends StatefulWidget {
  final TestInfo t;
  const TestScreen({super.key, required this.t});
  @override
  State<TestScreen> createState() => _TestState();
}

class _TestState extends State<TestScreen> {
  final int n = questions.length;
  late final List<int?> answers = List<int?>.filled(questions.length, null);
  int idx = 0;
  late int secs = widget.t.mins * 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (secs <= 1) {
        setState(() => secs = 0);
        _submit();
      } else {
        setState(() => secs--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _time =>
      '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';

  Future<void> _confirm() async {
    final un = answers.where((a) => a == null).length;
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('Submit test?'),
              content: Text(un == 0 ? 'You have answered all questions.' : '$un question(s) are unanswered.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Review')),
                FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Submit')),
              ],
            ));
    if (ok == true) _submit();
  }

  void _submit() {
    _timer?.cancel();
    if (!mounted) return;
    int c = 0, w = 0;
    for (var i = 0; i < n; i++) {
      if (answers[i] == null) continue;
      answers[i] == questions[i].ans ? c++ : w++;
    }
    AppState.i.addResult(TestResult(widget.t.title, c, n));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(t: widget.t, correct: c, wrong: w, total: n)));
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[idx];
    final low = secs < 60;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.t.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: (low ? Colors.red : kNavy).withOpacity(.1), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(Icons.timer, size: 16, color: low ? Colors.red : kNavy),
                const SizedBox(width: 4),
                Text(_time, style: TextStyle(fontWeight: FontWeight.w800, color: low ? Colors.red : kNavy)),
              ])),
          TextButton(onPressed: _confirm, child: const Text('Submit')),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: n,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final a = answers[i] != null;
              final cur = i == idx;
              return GestureDetector(
                onTap: () => setState(() => idx = i),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cur ? kNavy : (a ? kGreen : Colors.white),
                      border: Border.all(color: cur ? kNavy : (a ? kGreen : const Color(0xFFCDD0E3)))),
                  child: Text('${i + 1}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: (cur || a) ? Colors.white : kInk)),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Question ${idx + 1} of $n • ${answers.where((a) => a != null).length} answered', style: mS),
            const SizedBox(height: 8),
            Text(q.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk, height: 1.3)),
            const SizedBox(height: 18),
            for (var k = 0; k < q.opts.length; k++)
              GestureDetector(
                onTap: () => setState(() => answers[idx] = k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: answers[idx] == k ? kNavy.withOpacity(.07) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: answers[idx] == k ? kNavy : const Color(0xFFE1E3F0), width: 1.5)),
                  child: Row(children: [
                    CircleAvatar(
                        radius: 14,
                        backgroundColor: answers[idx] == k ? kNavy : const Color(0xFFEEF0F8),
                        child: Text(String.fromCharCode(65 + k),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: answers[idx] == k ? Colors.white : kInk))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(q.opts[k], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  ]),
                ),
              ),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: idx == 0 ? null : () => setState(() => idx--), child: const Text('Previous'))),
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: idx == n - 1 ? _confirm : () => setState(() => idx++),
                      child: Text(idx == n - 1 ? 'Submit Test' : 'Next'))),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ───────── Result ─────────
class ResultScreen extends StatelessWidget {
  final TestInfo t;
  final int correct, wrong, total;
  const ResultScreen({super.key, required this.t, required this.correct, required this.wrong, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (correct / total * 100).round();
    final msg = pct >= 80
        ? 'Excellent work! Keep practising to stay sharp.'
        : (pct >= 50
            ? 'Good effort! Revise the topics you missed and try again.'
            : 'Keep going! Review the lessons and retake the test.');
    Widget stat(String l, int v, Color c) => Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: cardDeco(),
              child: Column(children: [
                Text('$v', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c)),
                Text(l, style: mS),
              ])),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Result'), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                      value: pct / 100, strokeWidth: 12, backgroundColor: const Color(0xFFE6E8F3), color: kGreen)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$pct%', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: kInk)),
                Text('$correct / $total', style: mS),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          stat('Correct', correct, kGreen),
          const SizedBox(width: 10),
          stat('Incorrect', wrong, Colors.red),
          const SizedBox(width: 10),
          stat('Skipped', total - correct - wrong, kMuted),
        ]),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: cardDeco(), child: Text(msg, style: tS)),
        const SizedBox(height: 10),
        const Text('Scores are for demonstration only and are not real student results.',
            textAlign: TextAlign.center, style: mS),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: () => Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => TestScreen(t: t))),
            child: const Text('Retake Test')),
        const SizedBox(height: 10),
        OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Back to Home')),
      ]),
    );
  }
}

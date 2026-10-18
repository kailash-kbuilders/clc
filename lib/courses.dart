import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';
import 'tests.dart';

// ───────── My Courses ─────────
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesState();
}

class _CoursesState extends State<CoursesScreen> {
  bool _enrolled = true;
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = courses
        .where((c) => c.enrolled == _enrolled && c.title.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('My Courses', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Sample demo courses', style: mS)),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
              hintText: 'Search courses',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Enrolled')),
              ButtonSegment(value: false, label: Text('Explore')),
            ],
            selected: {_enrolled},
            onSelectionChanged: (s) => setState(() => _enrolled = s.first),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: list.isEmpty
            ? const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off, size: 54, color: kMuted),
                SizedBox(height: 8),
                Text('No courses found', style: tS),
                Text('Try a different search or tab', style: mS),
              ]))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final c in list)
                    CourseTile(c, onTap: () => push(context, CourseDetailScreen(course: c))),
                ],
              ),
      ),
    ]);
  }
}

// ───────── Course details ─────────
class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = course;
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: c.color),
              onPressed: () => push(context, LessonScreen(course: c, index: 2)),
              child: const Text('Continue Learning')),
        ),
      ),
      body: ListenableBuilder(
        listenable: AppState.i,
        builder: (_, __) => ListView(padding: EdgeInsets.zero, children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 22),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.color, c.color.withOpacity(.7)]),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft),
              Row(children: [
                Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(18)),
                    child: Icon(c.icon, color: Colors.white, size: 34)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.tag, style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(c.title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                ])),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                            value: c.progress, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white))),
                const SizedBox(width: 10),
                Text('${(c.progress * 100).round()}% (demo)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          const SectionTitle('Overview'),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                  '${c.desc}. This is an illustrative demo course with sample modules, notes and practice tests. Content is fictional.',
                  style: const TextStyle(color: kMuted, height: 1.4))),
          const SectionTitle('Modules & Lessons'),
          for (final e in modules.entries)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              decoration: cardDeco(),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                initiallyExpanded: e.key == 'Mental Ability',
                title: Text(e.key, style: tS),
                subtitle: Text('${e.value.length} items', style: mS),
                children: [
                  for (final l in e.value)
                    ListTile(
                      dense: true,
                      leading: Icon(lessonIcon(l.type), color: lessonColor(l.type)),
                      title: Text(l.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      subtitle: Text(l.dur, style: mS),
                      trailing: AppState.i.done.contains(l.id)
                          ? const Icon(Icons.check_circle, color: kGreen)
                          : const Icon(Icons.chevron_right, color: kMuted),
                      onTap: () => l.type == 'test'
                          ? push(context, TestInstructionsScreen(t: tests[1]))
                          : push(context, LessonScreen(course: c, index: allLessons.indexOf(l))),
                    ),
                ],
              ),
            ),
          const SectionTitle('Practice Tests'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: cardDeco(),
            child: Column(children: [
              for (final t in tests)
                ListTile(
                  leading: const Icon(Icons.quiz, color: kGreen),
                  title: Text(t.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text('${t.q} questions • ${t.mins} min • Sample test', style: mS),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => push(context, TestInstructionsScreen(t: t)),
                ),
            ]),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ───────── Lesson ─────────
class LessonScreen extends StatefulWidget {
  final Course course;
  final int index;
  const LessonScreen({super.key, required this.course, required this.index});
  @override
  State<LessonScreen> createState() => _LessonState();
}

class _LessonState extends State<LessonScreen> {
  int _step = 0;
  final List<String> _series = const ['2', '4', '8', '16', '32'];

  void _go(int i) => Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LessonScreen(course: widget.course, index: i)));

  @override
  Widget build(BuildContext context) {
    final l = allLessons[widget.index];
    final module = modules.entries.firstWhere((e) => e.value.contains(l)).key;
    final isLast = widget.index == allLessons.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(l.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      body: ListenableBuilder(
        listenable: AppState.i,
        builder: (_, __) {
          final done = AppState.i.done.contains(l.id);
          return ListView(padding: const EdgeInsets.all(16), children: [
            // Lesson header — no video. Interactive content instead.
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.course.color, const Color(0xFF0B0E3D)])),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(8)),
                      child: const Text('LESSON',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  const Spacer(),
                  const Icon(Icons.menu_book, color: Colors.white70, size: 20),
                ]),
                const SizedBox(height: 12),
                Text(l.title,
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('${widget.course.title} • $module • ${l.dur}',
                    style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 18),
            const SectionTitle('Concept'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDeco(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Find the pattern in this number series:', style: tS),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (var i = 0; i < _series.length; i++)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: i <= _step ? 1 : .15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        decoration: BoxDecoration(
                            color: i <= _step ? kNavy.withOpacity(.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: i <= _step ? kNavy : const Color(0xFFE1E3F0), width: 1.5)),
                        child: Text(_series[i],
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: i <= _step ? kNavy : kMuted)),
                      ),
                    ),
                ]),
                const SizedBox(height: 14),
                Text(
                    _step < _series.length - 1
                        ? 'Tap "Next step" to reveal each term and spot the rule.'
                        : 'Rule: each term doubles. So 16 × 2 = 32.',
                    style: mS),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: _step == 0 ? null : () => setState(() => _step--),
                          icon: const Icon(Icons.undo),
                          label: const Text('Back'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: FilledButton.icon(
                          onPressed: _step < _series.length - 1 ? () => setState(() => _step++) : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next step'))),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            Text(l.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 4),
            Text('${widget.course.title} • $module • ${l.dur}', style: mS),
            const SizedBox(height: 12),
            const Text(
                'A short, original sample lesson. In the real app this section would explain the concept, key tricks and what to practise next.',
                style: TextStyle(color: kMuted, height: 1.4)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () => snack(context, 'Simulated download — no real file in demo.'),
                      icon: const Icon(Icons.download),
                      label: const Text('Download Notes'))),
              const SizedBox(width: 10),
              Expanded(
                  child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: done ? kGreen : kNavy),
                      onPressed: () => AppState.i.toggleDone(l.id),
                      icon: Icon(done ? Icons.check_circle : Icons.check),
                      label: Text(done ? 'Completed' : 'Mark Complete'))),
            ]),
            const SectionTitle('Related Practice'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: cardDeco(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Q. Find the next number: 3, 6, 9, ?', style: tS),
                const SizedBox(height: 4),
                const Text('Sample question', style: mS),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: () => push(context, TestInstructionsScreen(t: tests[0])),
                    child: const Text('Practice more')),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: widget.index == 0 ? null : () => _go(widget.index - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'))),
              const SizedBox(width: 10),
              Expanded(
                  child: FilledButton.icon(
                      onPressed: isLast ? null : () => _go(widget.index + 1),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'))),
            ]),
          ]);
        },
      ),
    );
  }
}

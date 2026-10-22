import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'data.dart';
import 'widgets.dart';
import 'tests.dart';
import 'services/payment.dart';

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
    return ListenableBuilder(
      listenable: AppState.i,
      builder: (_, __) {
        final list = courses
            .where((c) =>
                AppState.i.owns(c) == _enrolled &&
                c.title.toLowerCase().contains(_q.toLowerCase()))
            .toList();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('My Courses',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk))),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Your courses and what is available', style: mS)),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('My Courses')),
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
                    Text('Nothing here yet', style: tS),
                    Text('Try the other tab or a different search', style: mS),
                  ]))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      for (final c in list)
                        CourseTile(
                          c,
                          owned: AppState.i.owns(c),
                          onTap: () => push(context, CourseDetailScreen(course: c)),
                          onBuy: () => buyCourse(context, c),
                        ),
                    ],
                  ),
          ),
        ]);
      },
    );
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
        child: ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) {
            final owned = AppState.i.owns(c);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: owned
                  ? FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: c.color),
                      onPressed: () => push(context, SubjectScreen(course: c, subject: c.subjects.first)),
                      child: const Text('Start Learning'))
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: kOrange),
                      onPressed: () => buyCourse(context, c),
                      icon: const Icon(Icons.lock_open),
                      label: Text('Buy for ₹${c.price}')),
            );
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: AppState.i,
        builder: (_, __) {
          final owned = AppState.i.owns(c);
          return ListView(padding: EdgeInsets.zero, children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [c.color, c.color.withOpacity(.7)]),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft),
                Row(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(c.image, width: 76, height: 76, fit: BoxFit.cover)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.tag,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(c.title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                              value: AppState.i.progressOf(c),
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              color: Colors.white))),
                  const SizedBox(width: 10),
                  Text('${(AppState.i.progressOf(c) * 100).round()}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ]),
            ),
            if (!owned)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: kOrange.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.lock, color: Color(0xFF9A5B00)),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text('Buy this course to open its subjects and classes.',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A5B00)))),
                ]),
              ),
            const SectionTitle('Overview'),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(c.desc, style: const TextStyle(color: kMuted, height: 1.4))),
            const SectionTitle('Subjects'),
            for (final s in c.subjects)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                decoration: cardDeco(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: s.color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                      child: Icon(s.icon, color: s.color)),
                  title: Text(s.title, style: tS),
                  subtitle: Text(
                      '${s.topics.length} topics • ${s.topics.fold(0, (a, t) => a + t.classes.length)} classes',
                      style: mS),
                  trailing: Icon(owned ? Icons.chevron_right : Icons.lock, color: kMuted),
                  onTap: () => owned
                      ? push(context, SubjectScreen(course: c, subject: s))
                      : buyCourse(context, c),
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
                    title: Text(t.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    subtitle: Text('${t.q} questions • ${t.mins} min', style: mS),
                    trailing: Icon(owned ? Icons.chevron_right : Icons.lock, color: kMuted),
                    onTap: () => owned
                        ? push(context, TestInstructionsScreen(t: t))
                        : buyCourse(context, c),
                  ),
              ]),
            ),
            const SizedBox(height: 18),
          ]);
        },
      ),
    );
  }
}

// ───────── Subject -> topics ─────────
class SubjectScreen extends StatelessWidget {
  final Course course;
  final Subject subject;
  const SubjectScreen({super.key, required this.course, required this.subject});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(subject.title)),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: [subject.color, subject.color.withOpacity(.7)])),
            child: Row(children: [
              Icon(subject.icon, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subject.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(course.title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 8),
          const SectionTitle('Topics'),
          for (final t in subject.topics)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: cardDeco(),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: subject.color.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.topic_outlined, color: subject.color)),
                title: Text(t.title, style: tS),
                subtitle: Text('${t.note}\n${t.classes.length} classes', style: mS),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right, color: kMuted),
                onTap: () => push(context,
                    TopicScreen(course: course, subject: subject, topic: t)),
              ),
            ),
        ]),
      );
}

// ───────── Topic -> classes ─────────
class TopicScreen extends StatelessWidget {
  final Course course;
  final Subject subject;
  final Topic topic;
  const TopicScreen(
      {super.key, required this.course, required this.subject, required this.topic});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(topic.title)),
        body: ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
            Text(topic.note, style: const TextStyle(color: kMuted, height: 1.4)),
            const SizedBox(height: 14),
            const Text('Classes', style: hS),
            const SizedBox(height: 8),
            for (var i = 0; i < topic.classes.length; i++)
              _classTile(context, i),
          ]),
        ),
      );

  Widget _classTile(BuildContext context, int i) {
    final k = topic.classes[i];
    final id = classId(course, subject, topic, k);
    final done = AppState.i.done.contains(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: cardDeco(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: subject.color.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.play_arrow_rounded, color: subject.color, size: 28)),
        title: Text('${i + 1}. ${k.title}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        subtitle: Text(k.dur, style: mS),
        trailing: done
            ? const Icon(Icons.check_circle, color: kGreen)
            : const Icon(Icons.chevron_right, color: kMuted),
        onTap: () => push(
            context,
            ClassPlayerScreen(
                course: course, subject: subject, topic: topic, item: k)),
      ),
    );
  }
}

// ───────── Class player (video + speed) ─────────
class ClassPlayerScreen extends StatefulWidget {
  final Course course;
  final Subject subject;
  final Topic topic;
  final ClassItem item;
  const ClassPlayerScreen(
      {super.key,
      required this.course,
      required this.subject,
      required this.topic,
      required this.item});
  @override
  State<ClassPlayerScreen> createState() => _ClassPlayerState();
}

class _ClassPlayerState extends State<ClassPlayerScreen> {
  late final VideoPlayerController _vc;
  bool _ready = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _vc = VideoPlayerController.asset(sampleVideo);
    _vc.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _vc.play();
    }).catchError((_) {
      if (mounted) setState(() => _ready = false);
    });
  }

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  void _setSpeed(double s) {
    setState(() => _speed = s);
    _vc.setPlaybackSpeed(s);
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final k = widget.item;
    final id = classId(c, widget.subject, widget.topic, k);
    return Scaffold(
      appBar: AppBar(title: Text(k.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      body: ListenableBuilder(
        listenable: AppState.i,
        builder: (_, __) {
          final done = AppState.i.done.contains(id);
          return ListView(padding: const EdgeInsets.all(16), children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: _ready ? _vc.value.aspectRatio : 16 / 9,
                  child: _ready
                      ? Stack(alignment: Alignment.center, children: [
                          VideoPlayer(_vc),
                          _playOverlay(),
                        ])
                      : const Center(
                          child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Loading class video...',
                              style: TextStyle(color: Colors.white70)),
                        )),
                ),
              ),
            ),
            if (_ready) ...[
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: _vc,
                builder: (_, v, __) => Row(children: [
                  Text(_fmt(v.position), style: mS),
                  Expanded(
                    child: Slider(
                      value: v.position.inMilliseconds
                          .clamp(0, v.duration.inMilliseconds)
                          .toDouble(),
                      max: v.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                      onChanged: (x) => _vc.seekTo(Duration(milliseconds: x.round())),
                    ),
                  ),
                  Text(_fmt(v.duration), style: mS),
                ]),
              ),
              Row(children: [
                const Text('Speed', style: mS),
                const SizedBox(width: 10),
                for (final s in [0.5, 1.0, 1.5, 2.0])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${s}x'),
                      selected: _speed == s,
                      onSelected: (_) => _setSpeed(s),
                    ),
                  ),
              ]),
            ],
            const SizedBox(height: 16),
            Text(k.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 4),
            Text('${widget.subject.title} • ${widget.topic.title} • ${k.dur}', style: mS),
            const SizedBox(height: 12),
            const Text(
                'Recorded class. Use the speed buttons to watch at 1.5x or 2x. New classes will be added here.',
                style: TextStyle(color: kMuted, height: 1.4)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: done ? kGreen : c.color),
                onPressed: () => AppState.i.toggleDone(id),
                icon: Icon(done ? Icons.check_circle : Icons.check),
                label: Text(done ? 'Completed' : 'Mark as complete'),
              ),
            ),
            const SectionTitle('Practice'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: cardDeco(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Practice this topic with a short test.', style: mS),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: () => push(context, TestInstructionsScreen(t: tests[0])),
                    child: const Text('Take a practice test')),
              ]),
            ),
          ]);
        },
      ),
    );
  }

  Widget _playOverlay() => ValueListenableBuilder(
        valueListenable: _vc,
        builder: (_, v, __) => AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: v.isPlaying ? 0 : 1,
          child: GestureDetector(
            onTap: () => setState(() => v.isPlaying ? _vc.pause() : _vc.play()),
            child: Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: const Icon(Icons.play_circle_fill, size: 72, color: Colors.white),
            ),
          ),
        ),
      );
}

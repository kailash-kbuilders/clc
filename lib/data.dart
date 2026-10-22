import 'package:flutter/material.dart';
import 'services/store.dart';
import 'services/cloud.dart';

/// One recorded class inside a topic.
///
/// [youtube]  – a YouTube link  -> plays online only (YouTube videos cannot be
///              downloaded inside an app).
/// [video]    – a direct video file link (mp4, e.g. from your own storage)
///              -> plays online AND can be saved for offline watching.
/// If both are empty, the bundled sample video is used.
class ClassItem {
  final String title, dur, youtube, video;
  const ClassItem(this.title, this.dur, [this.youtube = '', this.video = '']);
}

/// A topic (chapter) inside a subject.
class Topic {
  final String title, note;
  final List<ClassItem> classes;
  const Topic(this.title, this.note, this.classes);
}

/// A subject inside a course.
class Subject {
  final String title;
  final IconData icon;
  final Color color;
  final List<Topic> topics;
  const Subject(this.title, this.icon, this.color, this.topics);
}

class Course {
  final String id, title, desc, tag, image;
  final Color color;
  final bool free; // only one course is free
  final int price; // rupees (0 when free)
  final List<Subject> subjects;
  const Course(this.id, this.title, this.desc, this.tag, this.image, this.color,
      this.free, this.price, this.subjects);
}

/// Stable id for a class, used to remember what the student finished.
String classId(Course c, Subject s, Topic t, ClassItem k) =>
    '${c.id}|${s.title}|${t.title}|${k.title}';

int classCount(Course c) =>
    c.subjects.fold(0, (a, s) => a + s.topics.fold(0, (b, t) => b + t.classes.length));

const _sampleVideo = 'assets/video/class_preview.mp4';
String get sampleVideo => _sampleVideo;

const courses = [
  Course(
    'c1',
    'Navodaya Class 6 Foundation',
    'Mental Ability, Mathematics and Language',
    'FREE',
    'assets/courses/c1.jpg',
    Color(0xFF14196B),
    true,
    0,
    [
      Subject('Mental Ability', Icons.psychology, Color(0xFF6A3BD6), [
        Topic('Series and Patterns', 'Find the rule and continue the series.', [
          ClassItem('Introduction to Series', '10:00'),
          ClassItem('Number Series Practice', '12:00'),
          ClassItem('Letter Series', '09:00'),
        ]),
        Topic('Coding and Decoding', 'Letters and numbers ka code todna.', [
          ClassItem('Basics of Coding', '11:00'),
          ClassItem('Practice Set', '13:00'),
        ]),
      ]),
      Subject('Mathematics', Icons.calculate, Color(0xFF14196B), [
        Topic('Number System', 'Place value, operations and rounding.', [
          ClassItem('Number System Basics', '14:00'),
          ClassItem('Operations Practice', '12:00'),
        ]),
        Topic('Fractions and Decimals', 'Compare, add and simplify.', [
          ClassItem('Introduction to Fractions', '10:00'),
          ClassItem('Decimal Practice', '11:00'),
        ]),
      ]),
      Subject('Language', Icons.menu_book, Color(0xFF1B7A3A), [
        Topic('Grammar Essentials', 'Parts of speech and tenses.', [
          ClassItem('Parts of Speech', '12:00'),
          ClassItem('Tenses Made Easy', '11:00'),
        ]),
        Topic('Reading Practice', 'Passages and comprehension.', [
          ClassItem('Passage Reading', '09:00'),
        ]),
      ]),
    ],
  ),
  Course(
    'c2',
    'Mental Ability Practice',
    'Reasoning drills and pattern practice',
    'PAID',
    'assets/courses/c2.jpg',
    Color(0xFF6A3BD6),
    false,
    499,
    [
      Subject('Reasoning', Icons.extension, Color(0xFF6A3BD6), [
        Topic('Series', 'Number and figure series.', [
          ClassItem('Series Basics', '10:00'),
          ClassItem('Advanced Series', '13:00'),
        ]),
        Topic('Analogy', 'Relation between pairs.', [
          ClassItem('Analogy Introduction', '09:00'),
        ]),
        Topic('Odd One Out', 'Spot the different item.', [
          ClassItem('Odd One Out Practice', '11:00'),
        ]),
      ]),
    ],
  ),
  Course(
    'c3',
    'Sainik School Class 6 Preparation',
    'Maths, English, Intelligence and GK',
    'PAID',
    'assets/courses/c3.jpg',
    Color(0xFF2E7D32),
    false,
    699,
    [
      Subject('Mathematics', Icons.calculate, Color(0xFF2E7D32), [
        Topic('Arithmetic', 'Core arithmetic for the entrance.', [
          ClassItem('Arithmetic Basics', '14:00'),
          ClassItem('Word Problems', '15:00'),
        ]),
      ]),
      Subject('English', Icons.translate, Color(0xFF00838F), [
        Topic('Grammar', 'Tenses, articles and prepositions.', [
          ClassItem('Grammar Revision', '12:00'),
        ]),
      ]),
      Subject('Intelligence', Icons.lightbulb, Color(0xFFE65100), [
        Topic('Non-verbal Reasoning', 'Figures and patterns.', [
          ClassItem('Figure Patterns', '11:00'),
        ]),
      ]),
    ],
  ),
  Course(
    'c4',
    'Class 9 Entrance Preparation',
    'Maths, English, Science and Intelligence',
    'PAID',
    'assets/courses/c4.jpg',
    Color(0xFFE65100),
    false,
    599,
    [
      Subject('Mathematics', Icons.functions, Color(0xFFE65100), [
        Topic('Algebra', 'Expressions and equations.', [
          ClassItem('Algebra Basics', '15:00'),
        ]),
      ]),
      Subject('Science', Icons.science, Color(0xFF1B7A3A), [
        Topic('Physics Basics', 'Motion and force.', [
          ClassItem('Motion Introduction', '13:00'),
        ]),
      ]),
      Subject('English', Icons.menu_book, Color(0xFF14196B), [
        Topic('Comprehension', 'Reading and writing skills.', [
          ClassItem('Comprehension Practice', '12:00'),
        ]),
      ]),
    ],
  ),
];

/// A real question paper shown in the Tests tab.
class Paper {
  final String id, title, subject;
  final int pages;
  const Paper(this.id, this.title, this.subject, this.pages);

  /// Asset path of page n (1-based).
  String page(int n) => 'assets/paper/${id}_p${n.toString().padLeft(2, '0')}.jpg';
}

const papers = [
  Paper('jnv', 'JNV Navodaya Paper 2027 (Hindi Medium)', 'Navodaya / JNVST', 16),
];

class Note {
  final String title, subject, module, pages;
  const Note(this.title, this.subject, this.module, this.pages);
}

const notes = [
  Note('Mental Ability — Practice Set 01', 'Reasoning', 'Mental Ability', '8 pages'),
  Note('Mathematics — Number System Notes', 'Maths', 'Mathematics', '10 pages'),
  Note('English — Grammar Revision', 'English', 'Language Practice', '6 pages'),
];

class Notice {
  final String title, body, time;
  const Notice(this.title, this.body, this.time);
}

const notices = [
  Notice('New practice test available', 'Mental Ability sample test is now open.', 'Today'),
  Notice('Revision notes added', 'Number System notes added to Mathematics.', 'Yesterday'),
  Notice('Upcoming test reminder', 'Practice test tomorrow at 10:00 AM.', 'Yesterday'),
];

class PromoBanner {
  final String image, cta;
  final int tab;
  const PromoBanner(this.image, this.cta, this.tab);
}

const banners = [
  PromoBanner('assets/banners/b1.jpg', 'Explore Courses', 1),
  PromoBanner('assets/banners/b2.jpg', 'Start Practice', 2),
  PromoBanner('assets/banners/b3.jpg', 'Explore Courses', 1),
];

class TestResult {
  final String title;
  final int score, total;
  const TestResult(this.title, this.score, this.total);
}

/// Downloadable resources shown in the Downloads screen.
class Resource {
  final String id, title, subtitle, asset;
  final bool video;
  const Resource(this.id, this.title, this.subtitle, this.asset, this.video);
}

const resources = [
  Resource('video_demo', 'Sample class video', '10 sec • plays offline', 'assets/video/class_preview.mp4', true),
  Resource('paper_jnv', 'JNV Navodaya Paper 2027', '16 pages • question paper', 'assets/paper/jnv_p01.jpg', false),
];

/// App-wide state, persisted on the device.
class AppState extends ChangeNotifier {
  static final AppState i = AppState();

  final Set<String> done = {};
  final Set<int> read = {};
  final List<TestResult> results = [];
  final Set<String> purchased = {};
  final Set<String> downloaded = {};

  String userName = 'Student';
  String userClass = '';
  String userPhone = '';

  int get unread => notices.length - read.length;

  bool owns(Course c) => c.free || purchased.contains(c.id);

  void buy(Course c) {
    purchased.add(c.id);
    Store.savePurchased(purchased);
    Cloud.addPurchase(c.id); // so it comes back on any phone
    notifyListeners();
  }

  /// Replaces the purchase list (used when restoring an account from the cloud).
  void setPurchased(Set<String> ids) {
    purchased
      ..clear()
      ..addAll(ids);
    Store.savePurchased(purchased);
    notifyListeners();
  }

  void setProfile(String name, String cls) {
    userName = name;
    userClass = cls;
    Store.saveProfile(name, cls);
    notifyListeners();
  }

  void setPhone(String p) {
    userPhone = p;
    Store.setPhone(p);
    notifyListeners();
  }

  bool isDownloaded(String id) => downloaded.contains(id);

  void markDownloaded(String id, bool v) {
    v ? downloaded.add(id) : downloaded.remove(id);
    Store.saveDownloads(downloaded);
    notifyListeners();
  }

  /// How far the student has got through a course (0..1).
  double progressOf(Course c) {
    final ids = <String>[];
    for (final s in c.subjects) {
      for (final t in s.topics) {
        for (final k in t.classes) {
          ids.add(classId(c, s, t, k));
        }
      }
    }
    if (ids.isEmpty) return 0;
    return ids.where(done.contains).length / ids.length;
  }

  void hydrate() {
    done
      ..clear()
      ..addAll(Store.readDone());
    read
      ..clear()
      ..addAll(Store.readRead());
    results
      ..clear()
      ..addAll(Store.readResults().map((m) => TestResult(
            m['title'] as String,
            m['score'] as int,
            m['total'] as int,
          )));
    purchased
      ..clear()
      ..addAll(Store.readPurchased());
    downloaded
      ..clear()
      ..addAll(Store.readDownloads());
    userName = Store.profileName.isEmpty ? 'Student' : Store.profileName;
    userClass = Store.profileClass;
    userPhone = Store.phone;
    notifyListeners();
  }

  void toggleDone(String id) {
    done.contains(id) ? done.remove(id) : done.add(id);
    Store.saveDone(done);
    notifyListeners();
  }

  void markRead(int n) {
    read.add(n);
    Store.saveRead(read);
    notifyListeners();
  }

  void readAll() {
    read.addAll(List.generate(notices.length, (n) => n));
    Store.saveRead(read);
    notifyListeners();
  }

  void addResult(TestResult r) {
    results.insert(0, r);
    Store.saveResults(
        results.map((e) => {'title': e.title, 'score': e.score, 'total': e.total}).toList());
    notifyListeners();
  }
}

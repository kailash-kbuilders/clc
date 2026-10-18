import 'package:flutter/material.dart';
import 'services/store.dart';

class Course {
  final String id, title, desc, tag;
  final IconData icon;
  final Color color;
  final int lessons;
  final double progress;
  final bool free; // true = included free; only one course is free
  final int price; // price in rupees (0 when free)
  const Course(this.id, this.title, this.desc, this.tag, this.icon, this.color,
      this.lessons, this.progress, this.free, this.price);
}

const courses = [
  Course('c1', 'Navodaya Class 6 Foundation', 'Mental Ability, Mathematics and Language', 'FREE', Icons.psychology, Color(0xFF14196B), 24, .65, true, 0),
  Course('c2', 'Mental Ability Practice', 'Reasoning drills and pattern practice', 'PAID', Icons.extension, Color(0xFF6A3BD6), 18, 0, false, 499),
  Course('c3', 'Sainik School Class 6 Preparation', 'Maths, English, Intelligence and GK', 'PAID', Icons.military_tech, Color(0xFF2E7D32), 30, 0, false, 699),
  Course('c4', 'Class 9 Entrance Preparation', 'Maths, English, Science and Intelligence', 'PAID', Icons.rocket_launch, Color(0xFFE65100), 28, 0, false, 599),
];

class Lesson {
  final String id, title, type, dur;
  const Lesson(this.id, this.title, this.type, this.dur);
}

const modules = {
  'Introduction and Basics': [
    Lesson('l1', 'Course Orientation', 'read', '6 min'),
    Lesson('l2', 'How to Use This App', 'read', '4 min'),
  ],
  'Mental Ability': [
    Lesson('l3', 'Introduction to Mental Ability', 'read', '12 min'),
    Lesson('l4', 'Series and Patterns', 'read', '15 min'),
    Lesson('l5', 'Mental Ability Notes', 'pdf', '8 pages'),
  ],
  'Mathematics': [
    Lesson('l6', 'Number System Basics', 'read', '14 min'),
    Lesson('l7', 'Number System Notes', 'pdf', '10 pages'),
    Lesson('l8', 'Basics Practice Quiz', 'test', '10 Qs'),
  ],
  'Language Practice': [
    Lesson('l9', 'Grammar Essentials', 'read', '11 min'),
    Lesson('l10', 'Reading Practice', 'pdf', '6 pages'),
  ],
  'Revision and Mock Tests': [
    Lesson('l11', 'Revision Summary', 'read', '9 min'),
    Lesson('l12', 'Mock Test 01', 'test', '10 Qs'),
  ],
};

final allLessons = [for (final m in modules.values) ...m];

class Question {
  final String text;
  final List<String> opts;
  final int ans;
  const Question(this.text, this.opts, this.ans);
}

const questions = [
  Question('Find the next number: 2, 4, 8, 16, ?', ['24', '30', '32', '36'], 2),
  Question('Odd one out: Apple, Banana, Carrot, Mango', ['Apple', 'Banana', 'Carrot', 'Mango'], 2),
  Question('What is 15 + 27?', ['32', '42', '52', '62'], 1),
  Question('Find the next letter: A, C, E, G, ?', ['H', 'J', 'K', 'I'], 3),
  Question('What is 9 × 8?', ['64', '72', '81', '76'], 1),
  Question('What is 100 − 37?', ['53', '63', '73', '67'], 1),
  Question('Which decimal is the largest?', ['0.5', '0.25', '0.75', '0.6'], 2),
  Question('Opposite of "Hot" is…', ['Warm', 'Cold', 'Boil', 'Sun'], 1),
  Question('How many sides does a hexagon have?', ['5', '6', '7', '8'], 1),
  Question('Bird : Fly :: Fish : ?', ['Swim', 'Walk', 'Run', 'Jump'], 0),
];

class TestInfo {
  final String id, title, subject;
  final int q, mins;
  const TestInfo(this.id, this.title, this.subject, this.q, this.mins);
}

const tests = [
  TestInfo('t1', 'Mental Ability', 'Reasoning', 10, 10),
  TestInfo('t2', 'Mathematics Basics', 'Mathematics', 10, 15),
  TestInfo('t3', 'Navodaya Mixed Practice', 'Mixed', 10, 20),
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
  final String title, sub, cta;
  final List<Color> colors;
  final IconData icon;
  final int tab;
  const PromoBanner(this.title, this.sub, this.cta, this.colors, this.icon, this.tab);
}

const banners = [
  PromoBanner('Your Goal. Our Guidance.', 'Navodaya & Sainik style entrance preparation.', 'Explore Courses', [Color(0xFF14196B), Color(0xFF3A42D4)], Icons.emoji_events, 1),
  PromoBanner('Practice Today. Improve Tomorrow.', 'Mock tests and practice sets to track growth.', 'Start Practice', [Color(0xFFE65100), Color(0xFFFFA726)], Icons.edit_note, 2),
  PromoBanner('Build Strong Foundations.', 'Class 6 foundation preparation, step by step.', 'Explore Courses', [Color(0xFF1B7A3A), Color(0xFF55C26B)], Icons.auto_stories, 1),
];

class TestResult {
  final String title;
  final int score, total;
  const TestResult(this.title, this.score, this.total);
}

/// App-wide state. Everything here is persisted to the device so it
/// survives closing and reopening the app.
class AppState extends ChangeNotifier {
  static final AppState i = AppState();

  final Set<String> done = {};
  final Set<int> read = {};
  final List<TestResult> results = [];
  final Set<String> purchased = {};

  String userName = 'Student';
  String userClass = '';

  int get unread => notices.length - read.length;

  /// True if the course is free or has already been bought.
  bool owns(Course c) => c.free || purchased.contains(c.id);

  void buy(Course c) {
    purchased.add(c.id);
    Store.savePurchased(purchased);
    notifyListeners();
  }

  void setProfile(String name, String cls) {
    userName = name;
    userClass = cls;
    Store.saveProfile(name, cls);
    notifyListeners();
  }

  /// Loads saved data from the device. Call once after Store.init().
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
    userName = Store.profileName.isEmpty ? 'Student' : Store.profileName;
    userClass = Store.profileClass;
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

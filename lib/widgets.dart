import 'dart:async';
import 'package:flutter/material.dart';
import 'data.dart';

const kNavy = Color(0xFF14196B);
const kOrange = Color(0xFFF5A623);
const kGreen = Color(0xFF3FA535);
const kInk = Color(0xFF1B1F3B);
const kMuted = Color(0xFF6B7090);

const hS = TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kInk);
const tS = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kInk);
const mS = TextStyle(fontSize: 12, color: kMuted);

ThemeData buildTheme() {
  final cs = ColorScheme.fromSeed(seedColor: kNavy).copyWith(primary: kNavy, secondary: kOrange);
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: const Color(0xFFF4F5FA),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: kInk,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kInk)),
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white, indicatorColor: kNavy.withOpacity(.12)),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
  );
}

BoxDecoration cardDeco([Color c = Colors.white]) => BoxDecoration(
    color: c,
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [BoxShadow(color: Color(0x14141B4B), blurRadius: 14, offset: Offset(0, 5))]);

void push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

void snack(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
}

IconData lessonIcon(String t) => t == 'read'
    ? Icons.article
    : (t == 'pdf' ? Icons.picture_as_pdf : Icons.quiz);
Color lessonColor(String t) =>
    t == 'read' ? kNavy : (t == 'pdf' ? const Color(0xFFD84315) : kGreen);

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) => ClipOval(
        child: Image.asset('assets/logo.jpg',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                color: kNavy,
                alignment: Alignment.center,
                child: Text('CLC',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: size * .3)))),
      );
}

class DemoChip extends StatelessWidget {
  final bool dark;
  const DemoChip({super.key, this.dark = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: dark ? Colors.white.withOpacity(.15) : kOrange.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kOrange)),
        child: Text('DEMO APP',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
                color: dark ? kOrange : const Color(0xFF9A5B00))),
      );
}

class SectionTitle extends StatelessWidget {
  final String t;
  final String? sub;
  const SectionTitle(this.t, {super.key, this.sub});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: hS),
          if (sub != null) Text(sub!, style: mS),
        ]),
      );
}

class AppProgress extends StatelessWidget {
  final double v;
  final Color color;
  const AppProgress(this.v, {super.key, this.color = kGreen});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
            value: v, minHeight: 7, backgroundColor: const Color(0xFFE6E8F3), color: color),
      );
}

class TagChip extends StatelessWidget {
  final String t;
  final Color color;
  const TagChip(this.t, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
        child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
      );
}

/// Horizontal course card (Home)
class CourseCard extends StatelessWidget {
  final Course c;
  final VoidCallback onTap;
  const CourseCard(this.c, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12, bottom: 6),
        decoration: cardDeco(),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 92,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.color, c.color.withOpacity(.65)])),
            child: Stack(children: [
              Positioned(
                  right: -10,
                  bottom: -14,
                  child: Icon(c.icon, size: 86, color: Colors.white.withOpacity(.3))),
              Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text(c.tag,
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w800, color: c.color)))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 4),
              Text(c.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: mS),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 36), backgroundColor: c.color),
                      onPressed: onTap,
                      child: const Text('View Course', style: TextStyle(fontSize: 13)))),
            ]),
          ),
        ]),
      );
}

/// Full-width course tile (My Courses)
class CourseTile extends StatelessWidget {
  final Course c;
  final VoidCallback onTap;
  const CourseTile(this.c, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: cardDeco(),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [c.color, c.color.withOpacity(.6)])),
                  child: Icon(c.icon, color: Colors.white, size: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    TagChip(c.enrolled ? 'ENROLLED' : 'SAMPLE', c.enrolled ? kGreen : kMuted),
                  ]),
                  const SizedBox(height: 4),
                  Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: tS),
                  const SizedBox(height: 4),
                  Text('${c.lessons} lessons', style: mS),
                  if (c.enrolled) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(child: AppProgress(c.progress)),
                      const SizedBox(width: 8),
                      Text('${(c.progress * 100).round()}%', style: mS),
                    ]),
                  ],
                ]),
              ),
              const Icon(Icons.chevron_right, color: kMuted),
            ]),
          ),
        ),
      );
}

/// Reusable auto-sliding promotional carousel
class BannerCarousel extends StatefulWidget {
  final List<PromoBanner> items;
  final void Function(int tab) onCta;
  const BannerCarousel({super.key, required this.items, required this.onCta});
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _pc = PageController(viewportFraction: .93);
  int _i = 0;
  bool _hold = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_hold || !_pc.hasClients) return;
      _pc.animateToPage((_i + 1) % widget.items.length,
          duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _pc.dispose();
    super.dispose();
  }

  Widget _circle(double s, double o) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(o)));

  Widget _card(PromoBanner b) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: b.colors),
              boxShadow: [
                BoxShadow(
                    color: b.colors.first.withOpacity(.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8))
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(children: [
              Positioned(right: -40, top: -40, child: _circle(160, .08)),
              Positioned(right: 50, bottom: -60, child: _circle(130, .07)),
              Positioned(
                  right: 18,
                  bottom: 22,
                  child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white.withOpacity(.18)),
                      child: Icon(b.icon, size: 56, color: Colors.white))),
              Positioned(
                  right: 16,
                  top: 14,
                  child: Opacity(opacity: .95, child: const Logo(size: 30))),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 112, 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                height: 1.15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(b.sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.9), fontSize: 12, height: 1.25)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: b.colors.first,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18))),
                            onPressed: () => widget.onCta(b.tab),
                            child: Text(b.cta,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(
          height: 196,
          child: Listener(
            onPointerDown: (_) => _hold = true,
            onPointerUp: (_) => _hold = false,
            onPointerCancel: (_) => _hold = false,
            child: PageView.builder(
              controller: _pc,
              itemCount: widget.items.length,
              onPageChanged: (n) => setState(() => _i = n),
              itemBuilder: (_, n) => _card(widget.items[n]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var n = 0; n < widget.items.length; n++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: n == _i ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: n == _i ? kNavy : const Color(0xFFCDD0E3)),
            ),
        ]),
      ]);
}

/// One circular quick-action button (PW-style).
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const QuickAction(this.icon, this.label, this.color, this.onTap);
}

/// A prominent, horizontally scrollable row of circular quick-action
/// buttons, placed near the top of the home screen.
class QuickActions extends StatelessWidget {
  final List<QuickAction> items;
  const QuickActions({super.key, required this.items});

  Widget _button(QuickAction a) => SizedBox(
        width: 82,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: a.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: a.color.withOpacity(.12), shape: BoxShape.circle),
                  child: Icon(a.icon, color: a.color, size: 27)),
              const SizedBox(height: 8),
              Text(a.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kInk)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: cardDeco(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [for (final a in items) _button(a)]),
        ),
      );
}

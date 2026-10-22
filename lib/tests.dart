import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';
import 'library.dart';

// ───────── Tests (real question paper) ─────────
class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppState.i,
        builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
          const Text('Question paper and your results', style: mS),
          const SizedBox(height: 14),
          for (final p in papers) _paperCard(context, p),
          const SectionTitle('Your results'),
          if (AppState.i.results.isEmpty)
            const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Column(children: [
                  Icon(Icons.assignment_outlined, size: 54, color: kMuted),
                  SizedBox(height: 8),
                  Text('No results yet', style: tS),
                  Text('Attempt a paper to see it here', style: mS),
                ]))
          else
            Container(
              decoration: cardDeco(),
              child: Column(children: [
                for (final r in AppState.i.results)
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: kGreen),
                    title: Text(r.title, style: tS),
                    subtitle: Text('Score ${r.score}/${r.total}', style: mS),
                  ),
              ]),
            ),
        ]),
      );

  Widget _paperCard(BuildContext context, Paper p) => GestureDetector(
        onTap: () => push(context, PaperScreen(paper: p)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                  colors: [kNavy, Color(0xFF3A42D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
          child: Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(8)),
                  child: const Text('QUESTION PAPER',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              Text(p.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${p.subject} • ${p.pages} pages',
                  style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 12)),
              const SizedBox(height: 12),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration:
                      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Open paper',
                      style: TextStyle(
                          color: kNavy, fontWeight: FontWeight.w800, fontSize: 12))),
            ])),
            const Icon(Icons.description, size: 76, color: Colors.white24),
          ]),
        ),
      );
}

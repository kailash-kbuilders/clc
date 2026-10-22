import 'package:flutter/material.dart';
import 'data.dart';
import 'widgets.dart';
import 'services/downloads.dart';

// ───────── Question paper viewer ─────────
class PaperScreen extends StatelessWidget {
  final Paper paper;
  const PaperScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(paper.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: paper.pages,
          itemBuilder: (_, i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: cardDeco(),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              GestureDetector(
                onTap: () => push(context, _ZoomPage(paper: paper, page: i + 1)),
                child: Image.asset(paper.page(i + 1), fit: BoxFit.contain),
              ),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    Text('Page ${i + 1} of ${paper.pages}', style: mS),
                    const Spacer(),
                    const Icon(Icons.zoom_in, size: 16, color: kMuted),
                    const SizedBox(width: 4),
                    const Text('Tap to zoom', style: mS),
                  ])),
            ]),
          ),
        ),
      );
}

class _ZoomPage extends StatelessWidget {
  final Paper paper;
  final int page;
  const _ZoomPage({required this.paper, required this.page});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('Page $page', style: const TextStyle(fontSize: 15))),
        body: InteractiveViewer(
          maxScale: 5,
          child: Center(child: Image.asset(paper.page(page), fit: BoxFit.contain)),
        ),
      );
}

// ───────── Downloads ─────────
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});
  @override
  State<DownloadsScreen> createState() => _DownloadsState();
}

class _DownloadsState extends State<DownloadsScreen> {
  String? _busyId;

  Future<void> _download(Resource r) async {
    setState(() => _busyId = r.id);
    try {
      if (r.video) {
        await Downloads.saveOne(r.id, r.asset);
      } else {
        final p = papers.first;
        await Downloads.savePaper(r.id, p.id, p.pages);
      }
      AppState.i.markDownloaded(r.id, true);
      if (mounted) snack(context, '${r.title} downloaded for offline use.');
    } catch (_) {
      if (mounted) snack(context, 'Download failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(Resource r) async {
    setState(() => _busyId = r.id);
    try {
      if (r.video) {
        await Downloads.removeOne(r.id, r.asset);
      } else {
        final p = papers.first;
        await Downloads.removePaper(r.id, p.id, p.pages);
      }
      AppState.i.markDownloaded(r.id, false);
      if (mounted) snack(context, '${r.title} removed from downloads.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _open(Resource r) {
    if (r.video) {
      push(context, const _OfflineVideoScreen());
    } else {
      push(context, PaperScreen(paper: papers.first));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Downloads')),
        body: ListenableBuilder(
          listenable: AppState.i,
          builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Downloads',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
            const Text('Save classes and papers to use without internet', style: mS),
            const SizedBox(height: 14),
            for (final r in resources) _tile(r),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: kNavy.withOpacity(.07), borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [
                Icon(Icons.info_outline, color: kNavy),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Downloads are stored inside the app, so you can watch or read them without internet.',
                        style: TextStyle(fontSize: 12.5, height: 1.35))),
              ]),
            ),
          ]),
        ),
      );

  Widget _tile(Resource r) {
    final done = AppState.i.isDownloaded(r.id);
    final busy = _busyId == r.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardDeco(),
      child: Row(children: [
        Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: kNavy.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(r.video ? Icons.videocam : Icons.picture_as_pdf, color: kNavy)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.title, style: tS),
          const SizedBox(height: 2),
          Text(r.subtitle, style: mS),
        ])),
        if (busy)
          const SizedBox(
              width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
        else if (done)
          Row(children: [
            TextButton(onPressed: () => _open(r), child: const Text('Open')),
            IconButton(
                onPressed: () => _remove(r),
                icon: const Icon(Icons.delete_outline, color: Colors.red)),
          ])
        else
          FilledButton(
              style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 16)),
              onPressed: () => _download(r),
              child: const Text('Download', style: TextStyle(fontSize: 13))),
      ]),
    );
  }
}

class _OfflineVideoScreen extends StatelessWidget {
  const _OfflineVideoScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Downloaded class')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
                'This class is saved on your phone and plays without internet. Open it from the course to watch.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kMuted, height: 1.4)),
          ),
        ),
      );
}

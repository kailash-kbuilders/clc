import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Saves files into the app's own storage so they can be used offline.
///
/// In this demo the files ship with the app, so "download" copies them from
/// the app bundle into the app's documents folder — the same place a real
/// download from the internet would land. The flow is exactly what the live
/// app will use.
class Downloads {
  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final sub = Directory('${base.path}/clc');
    if (!await sub.exists()) await sub.create(recursive: true);
    return sub;
  }

  static Future<String> _save(String id, String assetPath) async {
    final dir = await _dir();
    final name = assetPath.split('/').last;
    final file = File('${dir.path}/${id}__$name');
    final data = await rootBundle.load(assetPath);
    await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return file.path;
  }

  static Future<String?> pathOf(String id, String assetPath) async {
    final dir = await _dir();
    final name = assetPath.split('/').last;
    final f = File('${dir.path}/${id}__$name');
    return await f.exists() ? f.path : null;
  }

  /// Downloads one asset (video or single image).
  static Future<void> saveOne(String id, String assetPath) async {
    await _save(id, assetPath);
  }

  /// Downloads a video from a direct link (mp4 etc.) into app storage.
  static Future<String> saveFromUrl(String id, String url) async {
    final dir = await _dir();
    final uri = Uri.parse(url);
    final name = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'class_$id.mp4';
    final file = File('${dir.path}/${id}__$name');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }

  /// Downloads every page of a paper.
  static Future<void> savePaper(String id, String paperId, int pages) async {
    for (var n = 1; n <= pages; n++) {
      final a = 'assets/paper/${paperId}_p${n.toString().padLeft(2, '0')}.jpg';
      await _save(id, a);
    }
  }

  static Future<void> removeOne(String id, String assetPath) async {
    final p = await pathOf(id, assetPath);
    if (p != null) await File(p).delete();
  }

  static Future<void> removePaper(String id, String paperId, int pages) async {
    for (var n = 1; n <= pages; n++) {
      final a = 'assets/paper/${paperId}_p${n.toString().padLeft(2, '0')}.jpg';
      await removeOne(id, a);
    }
  }

  /// Path of a downloaded paper page, or null if not downloaded.
  static Future<String?> paperPage(String id, String paperId, int n) async {
    final a = 'assets/paper/${paperId}_p${n.toString().padLeft(2, '0')}.jpg';
    return pathOf(id, a);
  }
}

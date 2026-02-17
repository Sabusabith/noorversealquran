import 'package:flutter/services.dart';

class LocalQuranSource {
  Future<Map<int, List<Map<String, dynamic>>>> loadQuran() async {
    final file = await rootBundle.loadString('assets/quran/quran_ar.txt');

    final lines = file.split('\n');

    Map<int, List<Map<String, dynamic>>> surahMap = {};

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|');

      final surah = int.parse(parts[0]);
      final ayah = int.parse(parts[1]);
      final text = parts[2];

      surahMap.putIfAbsent(surah, () => []);

      surahMap[surah]!.add({"number": ayah, "text": text});
    }

    return surahMap;
  }
}

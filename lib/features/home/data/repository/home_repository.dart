import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:noorversealquran/data/model/ayah_model.dart';
import 'package:noorversealquran/features/home/data/model/surah_model.dart.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

class QuranRepository {
  // Load surah metadata
  Future<List<Surah>> loadSurahMeta() async {
    final data = await rootBundle.loadString('assets/quran/surah_meta.json');
    final Map<String, dynamic> jsonData = json.decode(data);
    return jsonData.entries
        .map((e) => Surah.fromJson(e.value, int.parse(e.key)))
        .toList();
  }

  // Load Quran Arabic text
  Future<Map<int, List<Ayah>>> loadQuranAyahs() async {
    final data = await rootBundle.loadString('assets/quran/quran_ar.json');
    final Map<String, dynamic> jsonData = json.decode(data);

    return jsonData.map((key, value) {
      final ayahs = (value as List)
          .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(int.parse(key), ayahs);
    });
  }
}

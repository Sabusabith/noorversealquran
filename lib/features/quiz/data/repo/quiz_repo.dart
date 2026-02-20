import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:noorversealquran/features/quiz/data/model/quiz_model.dart';

class QuizRepository {
  Future<List<QuizModel>> loadQuiz() async {
    final data = await rootBundle.loadString('assets/quran/quiz.json');
    final List<dynamic> jsonResult = json.decode(data);

    return jsonResult.map((e) => QuizModel.fromJson(e)).toList();
  }
}

import 'dart:convert';

QuizModel quizModelFromJson(String str) => QuizModel.fromJson(json.decode(str));

class QuizModel {
  final Question question;
  final Options options;
  final Answer answer;

  QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    question: Question.fromJson(json["question"]),
    options: Options.fromJson(json["options"]),
    answer: Answer.fromJson(json["answer"]),
  );
}

class Question {
  final String en;
  final String ar;
  final String ml;

  Question({required this.en, required this.ar, required this.ml});

  factory Question.fromJson(Map<String, dynamic> json) =>
      Question(en: json["en"], ar: json["ar"], ml: json["ml"]);
}

class Options {
  final List<String> en;
  final List<String> ar;
  final List<String> ml;

  Options({required this.en, required this.ar, required this.ml});

  factory Options.fromJson(Map<String, dynamic> json) => Options(
    en: List<String>.from(json["en"]),
    ar: List<String>.from(json["ar"]),
    ml: List<String>.from(json["ml"]),
  );
}

class Answer {
  final String en;
  final String ar;
  final String ml;

  Answer({required this.en, required this.ar, required this.ml});

  factory Answer.fromJson(Map<String, dynamic> json) =>
      Answer(en: json["en"], ar: json["ar"], ml: json["ml"]);
}

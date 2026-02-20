import 'package:noorversealquran/features/quiz/data/model/quiz_model.dart';

enum QuizLanguage { en, ar, ml }

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizFinished extends QuizState {
  final int score;
  final int total;

  QuizFinished(this.score, this.total);
}

class LapCompleted extends QuizState {
  final int lap;
  final int lapScore;
  final int totalQuestionsInLap; // ✅ ADD THIS
  final int minimumRequired;
  final bool passed;

  LapCompleted({
    required this.lap,
    required this.lapScore,
    required this.totalQuestionsInLap, // ✅ ADD THIS
    required this.minimumRequired,
    required this.passed,
  });
}

class QuizLoaded extends QuizState {
  final List<QuizModel> questions;
  final int currentIndex;
  final int score;
  final QuizLanguage language;
  final bool isAnswered;
  final String? selectedAnswer;

  QuizLoaded({
    required this.questions,
    required this.currentIndex,
    required this.score,
    required this.language,
    this.isAnswered = false,
    this.selectedAnswer,
  });

  QuizLoaded copyWith({
    int? currentIndex,
    int? score,
    QuizLanguage? language,
    bool? isAnswered,
    String? selectedAnswer,
  }) {
    return QuizLoaded(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      language: language ?? this.language,
      isAnswered: isAnswered ?? this.isAnswered,
      selectedAnswer: selectedAnswer,
    );
  }
}

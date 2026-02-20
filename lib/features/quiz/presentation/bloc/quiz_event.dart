import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_state.dart';

abstract class QuizEvent {}

class LoadQuizEvent extends QuizEvent {}

class AnswerQuestionEvent extends QuizEvent {
  final String selectedAnswer;

  AnswerQuestionEvent(this.selectedAnswer);
}

class NextQuestionEvent extends QuizEvent {}

class ChangeLanguageEvent extends QuizEvent {
  final QuizLanguage language;

  ChangeLanguageEvent(this.language);
}

class RetryLapEvent extends QuizEvent {}

class ContinueAfterLapEvent extends QuizEvent {}

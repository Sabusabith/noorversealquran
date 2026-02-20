import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/features/quiz/data/model/quiz_model.dart';
import '../../data/repo/quiz_repo.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository repository;

  QuizBloc(this.repository) : super(QuizInitial()) {
    on<LoadQuizEvent>(_onLoadQuiz);
    on<AnswerQuestionEvent>(_onAnswer);
    on<NextQuestionEvent>(_onNext);
    on<ContinueAfterLapEvent>(_onContinue);
    on<RetryLapEvent>(_onRetryLap);
    on<ChangeLanguageEvent>(_onLanguageChange);
  }

  List<QuizModel> questions = [];

  int currentIndex = 0;
  int totalScore = 0;
  int lapScore = 0;

  int currentLap = 1;

  final int questionsPerLap = 12;
  final double minimumPercentage = 0.6; // 60%

  QuizLanguage currentLanguage = QuizLanguage.en;

  // ---------------- LOAD ----------------

  Future<void> _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) async {
    final loaded = await repository.loadQuiz();

    questions = List<QuizModel>.from(loaded)..shuffle(Random());

    currentIndex = 0;
    totalScore = 0;
    lapScore = 0;
    currentLap = 1;

    emit(
      QuizLoaded(
        questions: questions,
        currentIndex: currentIndex,
        score: totalScore,
        language: currentLanguage,
      ),
    );
  }

  // ---------------- ANSWER ----------------

  void _onAnswer(AnswerQuestionEvent event, Emitter<QuizState> emit) {
    if (state is! QuizLoaded) return;

    final question = questions[currentIndex];

    String correctAnswer;

    switch (currentLanguage) {
      case QuizLanguage.ar:
        correctAnswer = question.answer.ar;
        break;
      case QuizLanguage.ml:
        correctAnswer = question.answer.ml;
        break;
      default:
        correctAnswer = question.answer.en;
    }

    if (event.selectedAnswer == correctAnswer) {
      totalScore++;
      lapScore++;
    }

    emit(
      (state as QuizLoaded).copyWith(
        isAnswered: true,
        selectedAnswer: event.selectedAnswer,
        score: totalScore,
      ),
    );
  }

  // ---------------- NEXT ----------------

  void _onNext(NextQuestionEvent event, Emitter<QuizState> emit) {
    if (state is! QuizLoaded) return;

    final totalQuestions = questions.length;

    final lapStartIndex = (currentLap - 1) * questionsPerLap;
    final lapEndIndex = min(
      lapStartIndex + questionsPerLap - 1,
      totalQuestions - 1,
    );

    final questionsInThisLap = lapEndIndex - lapStartIndex + 1;

    // If lap finished
    if (currentIndex == lapEndIndex) {
      final minimumRequired = (questionsInThisLap * minimumPercentage).ceil();

      emit(
        LapCompleted(
          lap: currentLap,
          lapScore: lapScore,
          totalQuestionsInLap: questionsInThisLap, // ✅ FIX

          minimumRequired: minimumRequired,
          passed: lapScore >= minimumRequired,
        ),
      );

      return;
    }

    // If quiz finished completely
    if (currentIndex == totalQuestions - 1) {
      emit(QuizFinished(totalScore, totalQuestions));
      return;
    }

    currentIndex++;

    emit(
      (state as QuizLoaded).copyWith(
        currentIndex: currentIndex,
        isAnswered: false,
        selectedAnswer: null,
      ),
    );
  }

  // ---------------- CONTINUE ----------------

  void _onContinue(ContinueAfterLapEvent event, Emitter<QuizState> emit) {
    final totalQuestions = questions.length;

    // If already at last question → finish quiz
    if (currentIndex >= totalQuestions - 1) {
      emit(QuizFinished(totalScore, totalQuestions));
      return;
    }

    currentLap++;
    lapScore = 0;
    currentIndex++;

    emit(
      QuizLoaded(
        questions: questions,
        currentIndex: currentIndex,
        score: totalScore,
        language: currentLanguage,
      ),
    );
  }

  // ---------------- RETRY LAP ----------------

  void _onRetryLap(RetryLapEvent event, Emitter<QuizState> emit) {
    final lapStartIndex = (currentLap - 1) * questionsPerLap;

    currentIndex = lapStartIndex;
    lapScore = 0;

    emit(
      QuizLoaded(
        questions: questions,
        currentIndex: currentIndex,
        score: totalScore,
        language: currentLanguage,
      ),
    );
  }

  // ---------------- LANGUAGE ----------------

  void _onLanguageChange(ChangeLanguageEvent event, Emitter<QuizState> emit) {
    if (state is! QuizLoaded) return;

    currentLanguage = event.language;

    emit((state as QuizLoaded).copyWith(language: currentLanguage));
  }
}

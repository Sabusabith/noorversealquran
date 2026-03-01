import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/quiz/data/repo/quiz_repo.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:noorversealquran/features/quiz/presentation/pages/helper/dialogue_sheet.dart';
import 'package:confetti/confetti.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(QuizRepository())..add(LoadQuizEvent()),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
            size: 16,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Islamic Quiz",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizLoaded) {
            return _QuizLoadedView(state: state);
          }

          // ✅ FIX 1: HANDLE LAP COMPLETED
          if (state is LapCompleted) {
            return _LapCompletedView(state: state);
          }

          // ✅ FIX 2: HANDLE FINISHED
          if (state is QuizFinished) {
            return _QuizFinishedView(state: state);
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final quizBloc = context.read<QuizBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(value: quizBloc, child: LanguageSheet());
      },
    );
  }
}

class _QuizLoadedView extends StatelessWidget {
  final QuizLoaded state;

  const _QuizLoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuizBloc>();

    if (state.currentIndex >= state.questions.length) {
      return const SizedBox();
    }

    final question = state.questions[state.currentIndex];

    /// 🔥 LAP CALCULATION
    /// 🔥 SAFE LAP CALCULATION (Handles Last Lap Correctly)

    final totalQuestions = state.questions.length;
    final questionsPerLap = bloc.questionsPerLap;

    // Current lap
    final currentLap = (state.currentIndex ~/ questionsPerLap) + 1;

    // Lap start index
    final lapStartIndex = (currentLap - 1) * questionsPerLap;

    // Lap end index (SAFE for last lap)
    final lapEndIndex = min(lapStartIndex + questionsPerLap, totalQuestions);

    // How many questions actually in this lap
    final questionsInThisLap = lapEndIndex - lapStartIndex;

    // Position inside current lap
    final indexInsideLap = state.currentIndex - lapStartIndex;

    // Progress
    final double lapProgress = (indexInsideLap + 1) / questionsInThisLap;

    String questionText;
    List<String> options;
    String correctAnswer;

    switch (state.language) {
      case QuizLanguage.ar:
        questionText = question.question.ar;
        options = question.options.ar;
        correctAnswer = question.answer.ar;
        break;
      case QuizLanguage.ml:
        questionText = question.question.ml;
        options = question.options.ml;
        correctAnswer = question.answer.ml;
        break;
      default:
        questionText = question.question.en;
        options = question.options.en;
        correctAnswer = question.answer.en;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1FA2FF), Color(0xff12D8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              /// 🔥 TOP ROW (Lap + Score)
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lap $currentLap",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Score: ${bloc.lapScore} / $questionsInThisLap",
                    style: GoogleFonts.publicSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // ElevatedButton(
              //   onPressed: () {
              //     final bloc = context.read<QuizBloc>();
              //     final totalQuestions = bloc.questions.length;
              //     final totalLaps = (totalQuestions / bloc.questionsPerLap)
              //         .ceil();

              //     bloc.currentLap = totalLaps;
              //     bloc.currentIndex = (totalLaps - 1) * bloc.questionsPerLap;

              //     bloc.emit(
              //       QuizLoaded(
              //         questions: bloc.questions,
              //         currentIndex: bloc.currentIndex,
              //         score: bloc.totalScore,
              //         language: bloc.currentLanguage,
              //       ),
              //     );
              //   },
              //   child: Text("Jump To Last Lap"),
              // ),

              /// 🔥 LAP BASED PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: lapProgress,
                  minHeight: 8,
                  color: Colors.yellow,
                  backgroundColor: Colors.white24,
                ),
              ),

              const SizedBox(height: 25),

              /// QUESTION CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  questionText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// OPTIONS
              Expanded(
                child: ListView(
                  children: options.map((option) {
                    Color buttonColor = Colors.white.withOpacity(0.3);

                    if (state.isAnswered) {
                      if (option == correctAnswer) {
                        buttonColor = Colors.green;
                      } else if (option == state.selectedAnswer) {
                        buttonColor = Colors.red;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.grey.shade100,
                            shadowColor: Colors.transparent.withOpacity(.3),
                            elevation: 6,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            if (!state.isAnswered) {
                              context.read<QuizBloc>().add(
                                AnswerQuestionEvent(option),
                              );
                            }
                          },
                          child: Text(
                            option,
                            style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (state.isAnswered)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    context.read<QuizBloc>().add(NextQuestionEvent());
                  },
                  child: Text(
                    "Next Question",
                    style: GoogleFonts.publicSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _LapCompletedView extends StatelessWidget {
  final LapCompleted state;

  const _LapCompletedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final double percentage = (state.lapScore / state.totalQuestionsInLap)
        .clamp(0, 1);

    final int percentText = (percentage * 100).round();

    final bool passed = state.passed;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [Colors.green, const Color.fromARGB(255, 40, 98, 42)]
              : [Color(0xffFF512F), Color(0xffDD2476)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🔥 TITLE
                Text(
                  passed
                      ? "Lap ${state.lap} Completed 🎉"
                      : "Lap ${state.lap} Failed",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                /// 🔥 SCORE CIRCLE
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$percentText%",
                          style: GoogleFonts.publicSans(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${state.lapScore} / ${state.totalQuestionsInLap}",
                          style: GoogleFonts.publicSans(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// 🔥 MINIMUM REQUIRED INFO
                if (!passed)
                  Text(
                    "Minimum Required: ${state.minimumRequired}",
                    style: GoogleFonts.publicSans(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                const SizedBox(height: 45),

                /// 🔥 BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: passed ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {
                      if (passed) {
                        context.read<QuizBloc>().add(ContinueAfterLapEvent());
                      } else {
                        context.read<QuizBloc>().add(RetryLapEvent());
                      }
                    },
                    child: Text(
                      passed ? "Continue to Next Lap" : "Retry Lap",
                      style: GoogleFonts.publicSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizFinishedView extends StatefulWidget {
  final QuizFinished state;

  const _QuizFinishedView({required this.state});

  @override
  State<_QuizFinishedView> createState() => _QuizFinishedViewState();
}

class _QuizFinishedViewState extends State<_QuizFinishedView>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    )..play();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = widget.state.score / widget.state.total;

    final int percentText = (percentage * 100).round();

    int stars = 1;
    if (percentage >= 0.9) {
      stars = 3;
    } else if (percentage >= 0.7) {
      stars = 2;
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Color.fromARGB(255, 65, 168, 69),
                Color.fromARGB(255, 55, 172, 58),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        /// 🎊 Confetti
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2,
          emissionFrequency: 0.05,
          numberOfParticles: 30,
          maxBlastForce: 20,
          minBlastForce: 8,
          gravity: 0.2,
        ),

        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "🎉 Congratulations! 🎉",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// 🔥 Animated Score Circle
                    Container(
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$percentText%",
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${widget.state.score}/${widget.state.total}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// ⭐ Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 34,
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    /// 🔁 Restart Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          context.read<QuizBloc>().add(LoadQuizEvent());
                        },
                        child: const Text(
                          "Restart Quiz",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

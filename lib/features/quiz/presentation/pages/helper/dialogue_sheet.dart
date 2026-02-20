import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_state.dart';

class LanguageSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuizBloc>();
    final state = bloc.state;

    QuizLanguage currentLang = QuizLanguage.en;
    if (state is QuizLoaded) {
      currentLang = state.language;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _buildLanguageTile(
              context,
              "English",
              QuizLanguage.en,
              currentLang,
            ),
            _buildLanguageTile(context, "Arabic", QuizLanguage.ar, currentLang),
            _buildLanguageTile(
              context,
              "Malayalam",
              QuizLanguage.ml,
              currentLang,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String title,
    QuizLanguage language,
    QuizLanguage currentLang,
  ) {
    final isSelected = language == currentLang;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<QuizBloc>().add(ChangeLanguageEvent(language));
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.black.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Color(0xff1FA2FF) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.publicSans(fontSize: 16)),
              if (isSelected)
                Icon(Icons.check, size: 20, color: Color(0xff1FA2FF)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:noorversealquran/features/quiz/presentation/bloc/quiz_state.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<QuizBloc>();
    final state = bloc.state;

    QuizLanguage currentLang = QuizLanguage.en;
    if (state is QuizLoaded) {
      currentLang = state.language;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Drag Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Select Language",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
    final theme = Theme.of(context);
    final isSelected = language == currentLang;
    final isDark = theme.brightness == Brightness.dark;
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
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.dividerColor.withOpacity(.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (isSelected)
                Icon(Icons.check, size: 20, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

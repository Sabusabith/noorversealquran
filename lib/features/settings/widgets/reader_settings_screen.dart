import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/settings/bloc/cubit/reader_settings_cubit.dart';
import 'package:noorversealquran/features/settings/bloc/cubit/reader_settings_state.dart';

class ReaderSettingsPage extends StatelessWidget {
  const ReaderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Font Size", style: GoogleFonts.poppins(fontSize: 18)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onPrimary,
            size: 18,
          ),
        ),
      ),
      body: BlocBuilder<ReaderSettingsCubit, ReaderSettingsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ==============================
                /// ARABIC FONT SIZE
                /// ==============================
                Text(
                  "Arabic Font Size (${state.arabicFontSize.toInt()})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                SliderTheme(
                  data: _sliderTheme(theme),
                  child: Slider(
                    min: 18,
                    max: 40,
                    divisions: 11,
                    value: state.arabicFontSize,
                    label: state.arabicFontSize.toInt().toString(),
                    onChanged: (value) {
                      context.read<ReaderSettingsCubit>().updateArabic(value);
                    },
                  ),
                ),

                const SizedBox(height: 30),

                /// ==============================
                /// TRANSLATION FONT SIZE
                /// ==============================
                Text(
                  "Translation Font Size (${state.translationFontSize.toInt()})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                SliderTheme(
                  data: _sliderTheme(theme),
                  child: Slider(
                    min: 10,
                    max: 22,
                    divisions: 12,
                    value: state.translationFontSize,
                    label: state.translationFontSize.toInt().toString(),
                    onChanged: (value) {
                      context.read<ReaderSettingsCubit>().updateTranslation(
                        value,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                /// ==============================
                /// PREVIEW SECTION
                /// ==============================
                Text(
                  "Preview",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 20),

                _previewCard(
                  theme: theme,
                  title: "Arabic Preview",
                  text: "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                  fontSize: state.arabicFontSize,
                ),

                const SizedBox(height: 20),

                _previewCard(
                  theme: theme,
                  title: "Translation Preview",
                  text:
                      "In the name of Allah, the Most Gracious, the Most Merciful.",
                  fontSize: state.translationFontSize,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ==========================================
  /// SLIDER THEME (Dark & Light Mode Support)
  /// ==========================================
  SliderThemeData _sliderTheme(ThemeData theme) {
    final bool isDark = theme.brightness == Brightness.dark;

    final Color activeColor = isDark
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    final Color inactiveColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.3)
        : theme.colorScheme.primary.withOpacity(0.3);

    return SliderThemeData(
      activeTrackColor: activeColor,
      inactiveTrackColor: inactiveColor,
      thumbColor: activeColor,
      overlayColor: activeColor.withOpacity(0.2),
      valueIndicatorColor: activeColor,
      trackHeight: 4,

      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),

      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),

      valueIndicatorTextStyle: TextStyle(
        color: isDark ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// ==========================================
  /// PREVIEW CARD WIDGET
  /// ==========================================
  Widget _previewCard({
    required ThemeData theme,
    required String title,
    required String text,
    required double fontSize,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25)),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

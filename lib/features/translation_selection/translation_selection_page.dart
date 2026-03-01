import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';
import 'package:noorversealquran/utils/components/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TranslationSelectionPage extends StatefulWidget {
  final TranslationRepository translationRepo;

  const TranslationSelectionPage({super.key, required this.translationRepo});

  @override
  State<TranslationSelectionPage> createState() =>
      _TranslationSelectionPageState();
}

class _TranslationSelectionPageState extends State<TranslationSelectionPage> {
  bool translationEnabled = false;
  String? selectedLanguage;

  final Map<String, String> languages = {
    'ml': 'Malayalam',
    'en': 'English',
    'hi': 'Hindi',
    'de': 'German',
    'id': 'Indonesian',
    'tr': 'Turkish',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      translationEnabled = prefs.getBool('translation_enabled') ?? false;
      selectedLanguage =
          prefs.getString('selected_translation') ??
          (translationEnabled ? 'ml' : null);
    });
  }

  Future<void> _toggleTranslation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_enabled', value);

    setState(() {
      translationEnabled = value;
      widget.translationRepo.translationEnabled = value;

      if (!value) {
        selectedLanguage = null;
        widget.translationRepo.clearTranslations(); // resets flag
      }

      // 🔹 Print translation status
      print('Translation is now ${translationEnabled ? "ON" : "OFF"}');
    });
  }

  Future<void> _selectLanguage(String? lang) async {
    if (lang == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_translation', lang);

    // Load the translation JSON only if translation is enabled
    if (!translationEnabled) {
      print('Translation is OFF, language selection ignored');
      return;
    }

    if (lang == 'ml') {
      await widget.translationRepo.loadLanguage(
        'ml',
        'assets/quran/quran_ml.json',
      );
    } else if (lang == 'en') {
      await widget.translationRepo.loadLanguage(
        'en',
        'assets/quran/quran_en.json',
      );
    } else if (lang == 'hi') {
      await widget.translationRepo.loadLanguage(
        'hi',
        'assets/quran/quran_hi.json',
      );
    } else if (lang == 'de') {
      await widget.translationRepo.loadLanguage(
        'de',
        'assets/quran/quran_de.json',
      );
    } else if (lang == 'id') {
      await widget.translationRepo.loadLanguage(
        'id',
        'assets/quran/quran_id.json',
      );
    } else if (lang == 'tr') {
      await widget.translationRepo.loadLanguage(
        'tr',
        'assets/quran/quran_tr.json',
      );
    }

    setState(() {
      selectedLanguage = lang;
      print('Translation is ON, selected language: $selectedLanguage');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background for dropdown button
    final buttonBg = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.primary.withOpacity(0.05);

    // Text color
    final textColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.primary;

    // Hint color
    final hintColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.onSurface.withOpacity(0.6);

    // Border color
    final borderColor = theme.primaryColor.withOpacity(0.4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: theme.colorScheme.onPrimary,
            size: 16,
          ),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Translation Settings',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Toggle Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Translation',
                  style: GoogleFonts.catamaran(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Switch(
                  value: translationEnabled,
                  onChanged: _toggleTranslation,
                  activeColor: theme.colorScheme.secondary, // thumb when ON
                  activeTrackColor: theme.colorScheme.secondary.withOpacity(
                    0.4,
                  ), // track when ON
                  inactiveThumbColor: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade800, // thumb when OFF
                  inactiveTrackColor: isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200, // track when OFF
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Language Dropdown
            if (translationEnabled)
              Row(
                children: [
                  Text(
                    'Select Language:',
                    style: GoogleFonts.publicSans(fontSize: 15),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      // decoration: BoxDecoration(
                      //   color: kbgColor, // your soft cream tone
                      //   borderRadius: BorderRadius.circular(14),
                      //   border: Border.all(
                      //     color: kprimeryColor.withOpacity(0.4),
                      //     width: 1.2,
                      //   ),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withOpacity(0.04),
                      //       blurRadius: 6,
                      //       offset: const Offset(0, 3),
                      //     ),
                      //   ],
                      // ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          value: selectedLanguage,
                          hint: Text(
                            'Choose Language',
                            style: GoogleFonts.publicSans(
                              fontSize: 15,
                              color: hintColor,
                            ),
                          ),
                          items: languages.entries
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.key,
                                  child: Text(
                                    e.value,
                                    style: GoogleFonts.publicSans(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _selectLanguage,

                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: buttonBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey.shade600
                                    : theme.primaryColor.withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                          ),

                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDark ? Colors.white : theme.primaryColor,
                            ),
                            iconSize: 24,
                          ),

                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: theme.scaffoldBackgroundColor,
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

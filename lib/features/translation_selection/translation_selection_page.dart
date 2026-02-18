import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    'en': 'English', // future languages
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
    }

    setState(() {
      selectedLanguage = lang;
      print('Translation is ON, selected language: $selectedLanguage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    color: Colors.grey.shade800,
                  ),
                ),
                Switch(
                  activeColor: kprimeryColor,
                  value: translationEnabled,
                  onChanged: _toggleTranslation,
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
                      decoration: BoxDecoration(
                        color: kbgColor, // your soft cream tone
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kprimeryColor.withOpacity(0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedLanguage,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: kprimeryColor,
                          ),
                          hint: Text(
                            'Choose Language',
                            style: GoogleFonts.publicSans(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          dropdownColor: kbgColor,
                          style: GoogleFonts.publicSans(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          items: languages.entries
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.key,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Text(e.value),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _selectLanguage,
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

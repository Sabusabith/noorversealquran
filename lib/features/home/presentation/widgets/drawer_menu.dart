import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/home/presentation/widgets/about/about.dart';
import 'package:noorversealquran/features/quiz/presentation/pages/quiz_splash/quiz_splash.dart';
import 'package:noorversealquran/features/settings/settings.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:noorversealquran/features/translation_selection/translation_selection_page.dart';

class DrawerMenu extends StatelessWidget {
  final TranslationRepository translationRepo;

  const DrawerMenu({super.key, required this.translationRepo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          /// Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              children: [
                Image.asset("assets/images/quran.png", height: 80, width: 80),
                const SizedBox(height: 10),
                Text(
                  "NoorVerse",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Illuminate Your Heart",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// Menu Items
          _drawerItem(
            context,
            icon: Icons.translate,
            title: "Translation",
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TranslationSelectionPage(
                    translationRepo: translationRepo,
                  ),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            icon: Icons.extension,
            title: "Quiz",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizWelcomeScreen()),
              );
            },
          ),

          _drawerItem(
            context,
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),

          _drawerItem(
            context,
            icon: Icons.info_outline,
            title: "About",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      onTap: onTap,
    );
  }
}

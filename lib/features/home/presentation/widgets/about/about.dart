import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("About", style: GoogleFonts.poppins(fontSize: 18)),
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
        elevation: 0,
        backgroundColor: colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🌙 App Name
              Center(
                child: Text(
                  "NoorVerse",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "A Digital Quran Experience",
                  style: textTheme.bodySmall?.copyWith(
                    letterSpacing: 1.2,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 📖 About Section
              Text(
                "About the App",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "NoorVerse is a humble digital space created to help Muslims "
                "connect with the words of Allah in a calm and distraction-free "
                "environment. It brings the complete Holy Quran in a simple, "
                "beautiful, and elegant reading experience.\n\n"
                "This application was built with sincerity and care, "
                "seeking the pleasure of Allah and hoping it becomes "
                "a source of continuous benefit for every reader.",
                style: textTheme.bodyMedium?.copyWith(height: 1.7),
              ),

              const SizedBox(height: 30),

              /// 📚 Source Section
              Text(
                "Quran Text Source",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "The Quran text and translation used in this application "
                "are sourced from the quran-json package, which is based on "
                "the Tanzil Uthmani text provided by the Tanzil Project "
                "(tanzil.net). The Tanzil text is carefully verified and "
                "widely trusted for digital Quran applications.",
                style: textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
              const SizedBox(height: 8),

              Text(
                "© Tanzil Project",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 30),

              /// 🤲 Prayer Section
              Text(
                "A Prayer",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "We ask Allah to reward everyone who contributed "
                "to the development of this application — the scholars, "
                "developers, designers, and supporters.\n\n"
                "May Allah accept their efforts, forgive their shortcomings, "
                "and make this work a continuous charity (Sadaqah Jariyah) "
                "for them in this life and the Hereafter.\n\n"
                "اللهم تقبل منا واجعل هذا العمل خالصًا لوجهك الكريم.",
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 30),

              /// 📩 Report Issue Section
              Text(
                "Report an Issue",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "If you find any mistake in the Quran text, translation, "
                "or experience any issue while using the app, "
                "please let us know so we can improve it.",
                style: textTheme.bodyMedium?.copyWith(height: 1.7),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'sabusabith6@gmail.com',
                    queryParameters: {'subject': 'NoorVerse App Issue Report'},
                  );

                  await launchUrl(
                    emailUri,
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Text(
                  "📧 sabusabith6@gmail.com",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 🤍 Footer
              Center(
                child: Text(
                  "May this app be a source of light, guidance, and peace.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

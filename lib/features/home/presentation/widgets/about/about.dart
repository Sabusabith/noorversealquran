import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        title: Text(
          "About",
          style: GoogleFonts.publicSans(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kprimeryColor,
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
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "A Digital Quran Experience",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 📖 About Section
              Text(
                "About the App",
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "NoorVerse is a humble digital space created to help Muslims "
                "connect with the words of Allah in a calm and distraction-free "
                "environment. It brings the complete Holy Quran in a simple, "
                "beautiful, and elegant reading experience.\n\n"
                "This application was built with sincerity and care, "
                "seeking the pleasure of Allah and hoping it becomes "
                "a source of continuous benefit for every reader.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              /// 👨‍💻 Developer Section
              Text(
                "Developer",
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Developed by: Mohammed Sabith\n\n"
                "May Allah bless the efforts behind this work and "
                "make it sincerely for His sake.",
                style: TextStyle(fontSize: 15, height: 1.7),
              ),

              const SizedBox(height: 30),

              /// 📚 Source Section
              Text(
                "Quran Text Source",
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "The Quran text used in this application is provided "
                "by the Tanzil Project (tanzil.net). "
                "The text is carefully verified and widely trusted "
                "for digital Quran applications.",
                style: TextStyle(fontSize: 15, height: 1.7),
              ),

              const SizedBox(height: 8),

              const Text(
                "© Tanzil Project",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// 🤲 Prayer Section
              Text(
                "A Prayer",
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "We ask Allah to reward everyone who contributed "
                "to the development of this application — the scholars, "
                "developers, designers, and supporters.\n\n"
                "May Allah accept their efforts, forgive their shortcomings, "
                "and make this work a continuous charity (Sadaqah Jariyah) "
                "for them in this life and the Hereafter.\n\n"
                "اللهم تقبل منا واجعل هذا العمل خالصًا لوجهك الكريم.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 40),

              /// 🤍 Footer
              Center(
                child: Text(
                  "May this app be a source of light, guidance, and peace.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
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

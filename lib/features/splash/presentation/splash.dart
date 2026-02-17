import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/home/presentation/home.dart';
import 'package:noorversealquran/features/splash/bloc/splash_bloc.dart';
import 'package:noorversealquran/features/splash/bloc/splash_event.dart';
import 'package:noorversealquran/features/splash/bloc/splash_state.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const Color primary = Color(0xFF6D001A);
  static const Color gold = Color(0xFFD4AF37);
  static const Color white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
          );
        }
      },
      builder: (context, state) {
        String versionText = "";
        if (state is SplashLoaded) {
          versionText = state.version;
        }

        return Scaffold(
          backgroundColor: primary,
          body: Stack(
            children: [
              /// Center Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/quran.png",
                      height: 120,
                      width: 120,
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "السلام عليكم",
                      style: GoogleFonts.amiri(
                        color: white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "NoorVerse – Al Quran",
                      style: GoogleFonts.sourceSerif4(
                        color: gold.withOpacity(0.9),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              /// Bottom Version
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    versionText,
                    style: GoogleFonts.poppins(
                      color: kwhiteColor.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

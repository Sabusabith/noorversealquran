import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/home/presentation/home.dart';
import 'package:noorversealquran/features/splash/bloc/splash_bloc.dart';
import 'package:noorversealquran/features/splash/bloc/splash_state.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
        final theme = Theme.of(context);
        final primary = theme.colorScheme.primary;
        final isDark = theme.brightness == Brightness.dark;

        final secondary = theme.colorScheme.secondary;
        final onPrimary = theme.colorScheme.onPrimary;

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
                      style: TextStyle(
                        fontFamily: 'KFGQPCUthmanic',
                        color: onPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "NoorVerse – Al Quran",
                      style: GoogleFonts.sourceSerif4(
                        color: isDark
                            ? onPrimary.withOpacity(0.90)
                            : secondary.withOpacity(0.9),
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
                      color: onPrimary.withOpacity(0.4),
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

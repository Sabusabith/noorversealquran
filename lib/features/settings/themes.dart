import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/core/theme/cubit/theme_cubit.dart';
import 'package:noorversealquran/utils/components/theme.dart';

class Themes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Theme Settings", style: GoogleFonts.poppins(fontSize: 18)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onPrimary,
            size: 18,
          ),
        ),
      ),
      body: BlocBuilder<ThemeCubit, AppThemeType>(
        builder: (context, currentTheme) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              Text(
                "Choose App Theme",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _themeCard(
                context,
                title: "Maroon Gold",
                subtitle: "Classic Islamic Premium",
                theme: AppThemeType.maroonGold,
                currentTheme: currentTheme,
              ),

              _themeCard(
                context,
                title: "Emerald Green",
                subtitle: "Mosque Inspired",
                theme: AppThemeType.emeraldGreen,
                currentTheme: currentTheme,
              ),

              _themeCard(
                context,
                title: "Midnight Dark",
                subtitle: "Perfect for Night Reading",
                theme: AppThemeType.midnightDark,
                currentTheme: currentTheme,
              ),
              _themeCard(
                context,
                title: "Soft Dark",
                subtitle: "Comfortable Dark Mode",
                theme: AppThemeType.softDark,
                currentTheme: currentTheme,
              ),

              _themeCard(
                context,
                title: "Sand Beige",
                subtitle: "Soft & Peaceful",
                theme: AppThemeType.sandBeige,
                currentTheme: currentTheme,
              ),

              _themeCard(
                context,
                title: "Royal Blue",
                subtitle: "Modern Clean Look",
                theme: AppThemeType.royalBlue,
                currentTheme: currentTheme,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _themeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required AppThemeType theme,
    required AppThemeType currentTheme,
  }) {
    final bool isSelected = theme == currentTheme;

    return GestureDetector(
      onTap: () {
        context.read<ThemeCubit>().changeTheme(theme);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.palette_rounded,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

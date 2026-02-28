import 'package:flutter/material.dart';

class ReaderMenuBottomSheet extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleTranslation;
  final VoidCallback onChangeTheme;
  final VoidCallback onSelectReciter; // ✅ New callback for reciter

  const ReaderMenuBottomSheet({
    super.key,
    required this.onSelectReciter, // add here

    required this.isSaved,
    required this.onToggleBookmark,
    required this.onToggleTranslation,
    required this.onChangeTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Handle Bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              _menuItem(
                context,
                icon: Icons.info_outline,
                title: 'Info',
                onTap: onToggleBookmark,
              ),

              _menuItem(
                context,
                icon: Icons.translate,
                title: "Toggle Translation",
                onTap: onToggleTranslation,
              ),

              _menuItem(
                context,
                icon: Icons.record_voice_over,
                title: "Select Reciter",
                onTap: onSelectReciter, // ✅ Reciter action
              ),

              _menuItem(
                context,
                icon: Icons.color_lens_outlined,
                title: "Change Theme",
                onTap: onChangeTheme,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background
    final tileColor = isDark
        ? theme.colorScheme.surfaceVariant
        : theme.colorScheme.primary.withOpacity(0.08);

    // ✅ Always primary color
    final iconColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;

    // Text always readable
    final textColor = theme.colorScheme.onSurface;

    final arrowColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: tileColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: arrowColor),
          ],
        ),
      ),
    );
  }
}

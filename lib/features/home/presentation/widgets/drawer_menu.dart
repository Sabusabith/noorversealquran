import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kbgColor,
      child: Column(
        children: [
          /// Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: kprimeryColor, // maroon
            ),
            child: Column(
              children: [
                Image.asset("assets/images/quran.png", height: 80, width: 80),
                const SizedBox(height: 10),
                Text(
                  "NoorVerse",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: kwhiteColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Illuminate Your Heart",
                  style: GoogleFonts.poppins(fontSize: 12, color: kgoldColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// Menu Items
          _drawerItem(
            icon: Icons.menu_book_outlined,
            title: "Surahs",
            onTap: () {},
          ),

          _drawerItem(
            icon: Icons.bookmark_border,
            title: "Bookmarks",
            onTap: () {},
          ),

          _drawerItem(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {},
          ),

          _drawerItem(icon: Icons.info_outline, title: "About", onTap: () {}),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kprimeryColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

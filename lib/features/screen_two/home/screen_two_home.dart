import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/quiz/presentation/pages/quiz_splash/quiz_splash.dart';
import 'package:noorversealquran/features/screen_two/home/widgets/name_screen.dart';
import 'package:noorversealquran/features/screen_two/home/widgets/tasbeeh.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  final List<Map<String, dynamic>> features = const [
    {
      "title": "Names of Allah",
      "image": "assets/images/name.png",
      "colors": [Color(0xFF134E5E), Color(0xFF71B280)],
    },
    {
      "title": "Quiz",
      "image": "assets/images/ideas.png",
      "colors": [Color(0xFF11998E), Color.fromARGB(255, 6, 72, 31)],
    },
    {
      "title": "Tasbih Counter",
      "image": "assets/images/islamic.png",
      "colors": [Color(0xFF42275A), Color(0xFF734B6D)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              switch (features[index]["title"]) {
                case "Names of":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllahNamesPage()),
                  );
                  break;
                case "Quiz":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizWelcomeScreen(),
                    ),
                  );
                  break;
                case "Tasbih Counter":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitalTasbihPage(),
                    ),
                  );
                  break;
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: features[index]["colors"],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              height: 120, // fixed height for list item
              child: Stack(
                children: [
                  // RIGHT SIDE IMAGE
                  Positioned(
                    right: 15,
                    bottom: 15,
                    child: Image.asset(
                      features[index]["image"],
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // LEFT SIDE TEXT
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          features[index]["title"],
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Soft Decorative Glow
                  Positioned(
                    top: -30,
                    left: -30,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

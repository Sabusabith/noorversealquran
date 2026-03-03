import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/screen_two/home/widgets/preyer/vedio_page.dart';

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  static const Map<String, List<Map<String, dynamic>>> prayerLinks = {
    "Men": [
      {
        "title": "Fajr",
        "url": "https://youtu.be/YhgSe6DFK-0",
        "icon": "assets/images/Shalat-Dhuha.png",
      },
      {
        "title": "Dhuhr",
        "url": "https://youtu.be/zXjFF35J9PE",
        "icon": "assets/images/Shalat-Zhuhur.png",
      },
      {
        "title": "Asr",
        "url": "https://youtu.be/DcoNzaTl5ms",
        "icon": "assets/images/Shalat-Ashar.png",
      },
      {
        "title": "Maghrib",
        "url": "https://youtu.be/-7bw8v_MPmY",
        "icon": "assets/images/Shalat-Maghrib.png",
      },
      {
        "title": "Isha",
        "url": "https://youtu.be/b0B2TWuqgos",
        "icon": "assets/images/Shalat-Isya.png",
      },
    ],
    "Women": [
      {
        "title": "Fajr",
        "url": "https://youtu.be/WuiLWYlEuew",
        "icon": "assets/images/Shalat-Dhuha.png",
      },
      {
        "title": "Dhuhr",
        "url": "https://youtu.be/c0CiEqdJI0M",
        "icon": "assets/images/Shalat-Zhuhur.png",
      },
      {
        "title": "Asr",
        "url": "https://youtu.be/yMY3p57dTHo",
        "icon": "assets/images/Shalat-Ashar.png",
      },
      {
        "title": "Maghrib",
        "url": "https://youtu.be/2n2NZ-CtLdI",
        "icon": "assets/images/Shalat-Maghrib.png",
      },
      {
        "title": "Isha",
        "url": "https://youtu.be/dOHLdwGTuIk",
        "icon": "assets/images/Shalat-Isya.png",
      },
    ],
  };

  static const List<List<Color>> cardGradients = [
    [Color(0xFF4CAF50), Color(0xFF81C784)], // Green
    [Color(0xFF2196F3), Color(0xFF64B5F6)], // Blue
    [Color(0xFFFF9800), Color(0xFFFFB74D)], // Orange
    [Color(0xFF9C27B0), Color.fromARGB(255, 143, 63, 157)], // Purple
    [Color(0xFFE91E63), Color(0xFFF06292)], // Pink
  ];

  void _navigateToVideo(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrayerVideoPage(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Prayer Guide",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade500,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "Men"),
              Tab(text: "Women"),
            ],
          ),
        ),
        body: TabBarView(
          children: ["Men", "Women"].map((gender) {
            final prayers = prayerLinks[gender]!;
            final wuduUrl = gender == "Men"
                ? "https://youtu.be/eo3n_i-rHss"
                : "https://youtu.be/quVqtpkYwNI";
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Column(
                children: [
                  /// 🟢 WUDU SECTION (Long Parent Card)
                  InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => _navigateToVideo(
                      context,
                      "Wudu",
                      wuduUrl, // put your real link
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/wudu.png", // add your wudu icon
                            height: 60,
                            width: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              "Wudu Guide",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🔵 PRAYER GRID
                  Expanded(
                    child: GridView.builder(
                      itemCount: prayers.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1 / 1,
                          ),
                      itemBuilder: (context, index) {
                        final prayer = prayers[index];
                        final gradientColors =
                            cardGradients[index % cardGradients.length];

                        return InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _navigateToVideo(
                            context,
                            prayer["title"],
                            prayer["url"],
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradientColors,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  prayer["icon"],
                                  height: 60,
                                  width: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  prayer["title"],
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/data/model/ayah_model.dart';
import 'package:noorversealquran/features/home/data/model/surah_model.dart.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';

class SurahDetailsPage extends StatefulWidget {
  final Surah surah;
  final List<Ayah> ayahs;

  const SurahDetailsPage({super.key, required this.surah, required this.ayahs});

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  late List<String> pages;
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pages = _generatePages();
  }

  @override
  Widget build(BuildContext context) {
    final bool showBismillah = widget.surah.number != 9;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE),

      /// ---------------- APP BAR ----------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: kprimeryColor,
          centerTitle: true,
          iconTheme: IconThemeData(color: kwhiteColor),
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.surah.nameAr,
                  style: GoogleFonts.amiri(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: kwhiteColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// ---------------- BODY ----------------
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: PageView.builder(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() {
              currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: currentPage == index ? 1 : 0.4,
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    if (showBismillah && index == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Text(
                          "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(fontSize: 26, height: 2),
                        ),
                      ),

                    Expanded(
                      child: Text(
                        pages[index],
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.amiri(
                          fontSize: 25,
                          height: 2.2,
                          letterSpacing: 0.3,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // bottomNavigationBar: SafeArea(
      //   top: false,
      //   child: Container(
      //     padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      //     decoration: BoxDecoration(color: kprimeryColor.withOpacity(.6)),
      //     child: Directionality(
      //       textDirection: TextDirection.rtl,
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           Text(
      //             "${currentPage + 1} / ${pages.length}",
      //             style: const TextStyle(
      //               fontSize: 15,
      //               fontWeight: FontWeight.w600,
      //               color: Colors.white,
      //             ),
      //           ),
      //           const SizedBox(height: 10),

      //           LayoutBuilder(
      //             builder: (context, constraints) {
      //               final totalWidth = constraints.maxWidth;
      //               final indicatorWidth = totalWidth / pages.length;

      //               return Stack(
      //                 children: [
      //                   Container(
      //                     height: 4,
      //                     width: totalWidth,
      //                     decoration: BoxDecoration(
      //                       color: Colors.white24,
      //                       borderRadius: BorderRadius.circular(20),
      //                     ),
      //                   ),
      //                   AnimatedPositioned(
      //                     duration: const Duration(milliseconds: 350),
      //                     curve: Curves.easeInOut,
      //                     right: indicatorWidth * currentPage,
      //                     child: Container(
      //                       height: 4,
      //                       width: indicatorWidth,
      //                       decoration: BoxDecoration(
      //                         color: Colors.white,
      //                         borderRadius: BorderRadius.circular(20),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               );
      //             },
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  /// ---------------- PAGE SPLITTING ----------------
  List<String> _generatePages() {
    List<String> result = [];
    String buffer = "";

    const int maxCharsPerPage = 1100;

    for (final ayah in widget.ayahs) {
      final ayahText = "${ayah.text} ﴿${ayah.number}﴾ ";

      if (buffer.length + ayahText.length > maxCharsPerPage) {
        result.add(buffer);
        buffer = "";
      }

      buffer += ayahText;
    }

    if (buffer.isNotEmpty) {
      result.add(buffer);
    }

    return result;
  }
}

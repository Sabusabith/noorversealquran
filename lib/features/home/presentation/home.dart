import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noorversealquran/features/home/presentation/widgets/surah_detail_page.dart';
import '../bloc/home_bloc.dart';
import '../data/repository/home_repository.dart';
import 'widgets/drawer_menu.dart';
import '../../../utils/common/app_colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = HomeBloc(QuranRepository());
        bloc.add(LoadQuranData());
        return bloc;
      },
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TranslationRepository translationRepos = TranslationRepository();

  int? lastSavedSurahNumber;
  int? lastSavedPage;

  @override
  void initState() {
    super.initState();
    _loadLastSaved();
  }

  /// Load the last saved Surah and page
  Future<void> _loadLastSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSurah = prefs.getInt('last_saved_surah');
    final savedPage = prefs.getInt('last_saved_page');

    if (savedSurah != null && savedPage != null) {
      setState(() {
        lastSavedSurahNumber = savedSurah;
        lastSavedPage = savedPage;
      });
    }
  }

  /// Save a page globally (removes previous)
  Future<void> _saveLastPage(int surahNumber, int? page) async {
    final prefs = await SharedPreferences.getInstance();
    if (page == null) {
      await prefs.remove('last_saved_surah');
      await prefs.remove('last_saved_page');
      setState(() {
        lastSavedSurahNumber = null;
        lastSavedPage = null;
      });
    } else {
      await prefs.setInt('last_saved_surah', surahNumber);
      await prefs.setInt('last_saved_page', page);
      setState(() {
        lastSavedSurahNumber = surahNumber;
        lastSavedPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(translationRepo: translationRepos),
      appBar: AppBar(
        toolbarHeight: 70,
        title: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            bool isSearching = state is HomeLoaded ? state.isSearching : false;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isSearching
                  ? Container(
                      key: const ValueKey("searchField"),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "Search Surah...",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                        onChanged: (value) => context.read<HomeBloc>().add(
                          SearchTextChanged(value),
                        ),
                      ),
                    )
                  : Text(
                      "NoorVerse",
                      key: const ValueKey("title"),
                      style: GoogleFonts.sourceSerif4(color: kwhiteColor),
                    ),
            );
          },
        ),
        actions: [
          // Last saved page button
          if (lastSavedSurahNumber != null && lastSavedPage != null)
            IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.yellow),
              tooltip: "Go to last saved page",
              onPressed: () async {
                final blocState = context.read<HomeBloc>().state;
                if (blocState is HomeLoaded) {
                  final surah = blocState.filteredSurahs.firstWhere(
                    (s) => s.number == lastSavedSurahNumber,
                    orElse: () => blocState.filteredSurahs.first,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailsPage(
                        surah: surah,
                        ayahs: blocState.quran[surah.number] ?? [],
                        jumpToPage: lastSavedPage,
                        translationRepo: translationRepos, // <-- pass it here

                        onPageSaved: (page) async {
                          // Replace old saved page
                          await _saveLastPage(surah.number, page);
                        },
                      ),
                    ),
                  );
                }
              },
            ),

          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              bool isSearching = state is HomeLoaded
                  ? state.isSearching
                  : false;
              return IconButton(
                icon: Icon(
                  isSearching ? Icons.close : CupertinoIcons.search,
                  color: Colors.white,
                ),
                onPressed: () => context.read<HomeBloc>().add(ToggleSearch()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: kbgColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading)
            return Center(
              child: CircularProgressIndicator(color: kprimeryColor),
            );
          if (state is HomeError)
            return Center(child: Text("Error: ${state.message}"));
          if (state is HomeLoaded) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 24,
                ),
                itemCount: state.filteredSurahs.length,
                itemBuilder: (context, index) {
                  final surah = state.filteredSurahs[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          reverseTransitionDuration: const Duration(
                            milliseconds: 400,
                          ),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SurahDetailsPage(
                                    translationRepo: translationRepos,
                                    surah: surah,
                                    ayahs: state.quran[surah.number] ?? [],
                                    jumpToPage: null,

                                    onPageSaved: (page) async {
                                      await _saveLastPage(surah.number, page);
                                    },
                                  ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                // Slide from bottom + Fade in
                                const beginOffset = Offset(0, 1);
                                const endOffset = Offset.zero;
                                final tween = Tween(
                                  begin: beginOffset,
                                  end: endOffset,
                                ).chain(CurveTween(curve: Curves.easeOutCubic));
                                final fadeTween = Tween<double>(
                                  begin: 0,
                                  end: 1,
                                );

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: FadeTransition(
                                    opacity: animation.drive(fadeTween),
                                    child: child,
                                  ),
                                );
                              },
                        ),
                      );

                      _loadLastSaved(); // Refresh top AppBar icon if page saved
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEDF4F1),
                              ),
                              child: Text(
                                surah.number.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah.nameAr,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.amiri(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A1A),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    surah.tName,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              "assets/images/quran.png",
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

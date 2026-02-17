import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        toolbarHeight: 70,
        title: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            bool isSearching = false;
            if (state is HomeLoaded) isSearching = state.isSearching;

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
                        onChanged: (value) {
                          context.read<HomeBloc>().add(
                            SearchTextChanged(value),
                          );
                        },
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
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              bool isSearching = false;
              if (state is HomeLoaded) isSearching = state.isSearching;

              return IconButton(
                icon: Icon(
                  isSearching ? Icons.close : CupertinoIcons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.read<HomeBloc>().add(ToggleSearch());
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: kbgColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
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
                    onTap: () {
                      final state = context.read<HomeBloc>().state;
                      if (state is HomeLoaded) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailsPage(
                              surah: surah,
                              ayahs: state.quran[surah.number] ?? [],
                            ),
                          ),
                        );
                      }
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
                            // Surah Number Badge
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEDF4F1),
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

                            // Surah Names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Arabic Main Title
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

                                  // English Subtitle
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
          } else if (state is HomeError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

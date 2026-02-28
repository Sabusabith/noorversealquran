import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/data/model/ayah_model.dart';
import 'package:noorversealquran/features/home/data/model/surah_model.dart.dart';
import 'package:noorversealquran/features/home/presentation/widgets/surah_detail_page.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:noorversealquran/utils/local_storage.dart';

class BookmarkScreen extends StatefulWidget {
  final List<Surah> surahList;
  final Map<int, List<Ayah>> quran;
  final TranslationRepository translationRepo;

  const BookmarkScreen({
    super.key,
    required this.surahList,
    required this.quran,
    required this.translationRepo,
  });

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final data = await LocalStorage.getLastThreeBookmarks();
    setState(() => bookmarks = data);
  }

  Surah? getSurahByNumber(int number) {
    try {
      return widget.surahList.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
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
        title: Text("Bookmarks", style: GoogleFonts.poppins(fontSize: 18)),
        centerTitle: true,
        elevation: 1,
      ),
      backgroundColor: colorScheme.background,
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 60,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No bookmarks yet",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  final surah = getSurahByNumber(bookmark['surah']);

                  if (surah == null) return const SizedBox();

                  return Card(
                    color: colorScheme.surface,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: theme.brightness == Brightness.dark
                              ? colorScheme.secondary
                              : colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        surah.tName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        "Page ${bookmark['page'] + 1}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailsPage(
                              surah: surah,
                              ayahs: widget.quran[surah.number] ?? [],
                              jumpToPage: bookmark['page'],
                              translationRepo: widget.translationRepo,
                            ),
                          ),
                        );

                        loadBookmarks();
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

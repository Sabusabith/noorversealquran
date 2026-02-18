import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/home/data/model/surah_model.dart.dart';
import 'package:noorversealquran/data/model/ayah_model.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

class SurahDetailsPage extends StatefulWidget {
  final TranslationRepository translationRepo; // add this

  final Surah surah;
  final List<Ayah> ayahs;
  final int? jumpToPage;
  final Future<void> Function(int? page)? onPageSaved;

  const SurahDetailsPage({
    super.key,
    required this.surah,
    required this.ayahs,
    this.jumpToPage,
    required this.translationRepo, // add here

    this.onPageSaved,
  });

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage>
    with AutomaticKeepAliveClientMixin {
  late List<List<Ayah>> pagedAyahs;
  late PageController _pageController;

  int currentPage = 0;
  bool isSaved = false;
  bool _fontsLoaded = false;

  // ----- AUDIO VARIABLES -----
  late AudioPlayer _audioPlayer;
  ValueNotifier<int> currentAyahIndex = ValueNotifier<int>(-1);
  bool _isAudioPlaying = false;

  List<String> ayahAudioUrls = [];
  List<double> ayahTimings = []; // optional if you want precise timing

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pagedAyahs = _splitIntoPages(widget.ayahs);
    _loadSavedPage();
    _initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchAyahAudioUrls();
      _initAudio();
    });
    _loadSavedTranslation();
  }

  //load translation

  Future<void> _loadSavedTranslation() async {
    await widget.translationRepo.loadSettings();
    if (widget.translationRepo.translationEnabled &&
        widget.translationRepo.selectedLanguage != null) {
      await setTranslation(widget.translationRepo.selectedLanguage!);
    }
    setState(() {}); // Refresh UI
  }

  Future<void> setTranslation(String lang) async {
    if (lang == 'ml') {
      await widget.translationRepo.loadLanguage(
        'ml',
        'assets/quran/quran_ml.json',
      );
    } else if (lang == 'en') {
      await widget.translationRepo.loadLanguage(
        'en',
        'assets/quran/quran_en.json',
      );
    }
    // Add more languages here in the future

    setState(() {}); // Refresh UI to show translation
  }

  Future<void> _initialize() async {
    await GoogleFonts.pendingFonts([GoogleFonts.amiri()]);
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_page_surah_${widget.surah.number}';
    final saved = prefs.getInt(key);
    final startPage = widget.jumpToPage ?? saved ?? 0;

    _pageController = PageController(initialPage: startPage);

    setState(() {
      _fontsLoaded = true;
      currentPage = startPage;
      isSaved = saved != null;
    });
  }

  Future<void> _loadSavedPage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_page_surah_${widget.surah.number}';
    final saved = prefs.getInt(key);

    int startPage = widget.jumpToPage ?? saved ?? 0;

    setState(() {
      currentPage = startPage;
      isSaved = saved != null;
    });
  }

  Future<void> _toggleSavePage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_page_surah_${widget.surah.number}';

    if (isSaved) {
      await prefs.remove(key);
      setState(() => isSaved = false);
      if (widget.onPageSaved != null) await widget.onPageSaved!(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bookmark removed"),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await prefs.setInt(key, currentPage);
      setState(() => isSaved = true);
      if (widget.onPageSaved != null) await widget.onPageSaved!(currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Bookmark saved"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// Fetch per-Ayah audio URLs using Al-Quran Cloud API
  Future<void> _fetchAyahAudioUrls() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/surah/${widget.surah.number}/ar.alafasy',
        ),
      );
      if (response.statusCode != 200) throw Exception('Failed to load');

      final data = jsonDecode(response.body);
      final ayahsData = data['data']['ayahs'] as List;

      ayahAudioUrls = ayahsData.map((a) => a['audio'] as String).toList();
      print('Fetched ${ayahAudioUrls.length} ayah audio URLs');
    } catch (e) {
      print('Error fetching ayah audio: $e');
      // fallback to full surah audio
      ayahAudioUrls = [
        'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${widget.surah.number}.mp3',
      ];

      // Show error message if no internet
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       backgroundColor: Colors.red.shade600,
      //       content: const Text(
      //         "Audio may not load properly. Check your internet connection.",
      //       ),
      //     ),
      //   );
      // }
    }
  }

  void _initAudio() async {
    _audioPlayer = AudioPlayer();

    if (ayahAudioUrls.isEmpty) return;

    try {
      // Start from the first Ayah of the page if jumpToPage is provided
      int startIndex = (widget.jumpToPage ?? 0) * 7; // 7 ayahs per page
      if (startIndex >= ayahAudioUrls.length) startIndex = 0;

      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: ayahAudioUrls
              .map((url) => AudioSource.uri(Uri.parse(url)))
              .toList(),
        ),
        initialIndex: startIndex,
      );

      // Listen to player state to update play/pause icon
      _audioPlayer.playerStateStream.listen((state) {
        final isPlaying =
            state.playing && state.processingState != ProcessingState.completed;
        if (_isAudioPlaying != isPlaying)
          setState(() => _isAudioPlaying = isPlaying);
      });

      // Listen to current index to highlight Ayah & auto change page
      _audioPlayer.currentIndexStream.listen((index) {
        if (index != null) {
          currentAyahIndex.value = index;

          // Auto change page based on Ayah
          final newPage = index ~/ 7;
          if (newPage != currentPage) {
            _pageController.animateToPage(
              newPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
            setState(() => currentPage = newPage);
          }
        }
      });
      // Listen to playback errors
      _audioPlayer.playbackEventStream.listen(
        (_) {},
        onError: (Object e, StackTrace stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text("Audio playback error. Check your network."),
              ),
            );
          }
        },
      );

      // Optional: auto play if jumpToPage is set
      if (widget.jumpToPage != null) {
        await _audioPlayer.play();
        setState(() => _isAudioPlaying = true);
      }
    } catch (e) {
      print("Error loading audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Unable to load audio. Check your connection."),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    currentAyahIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_fontsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showBismillah = widget.surah.number != 9;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: kprimeryColor,
          onPressed: () => _toggleSavePage(),
          child: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: kprimeryColor,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.surah.nameAr,
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              widget.surah.tName,
              style: GoogleFonts.publicSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
            onPressed: _showSurahInfoDialog,
          ),
          // IconButton(
          //   icon: Icon(
          //     isSaved ? Icons.bookmark : Icons.bookmark_border,
          //     color: Colors.white,
          //     size: 20,
          //   ),
          //   onPressed: _toggleSavePage,
          // ),
          // Play button
          IconButton(
            icon: Icon(
              _isAudioPlaying ? Icons.pause : Icons.play_arrow,
              size: 22,
              color: _isAudioPlaying ? Colors.green : Colors.white,
            ),
            onPressed: () async {
              try {
                if (ayahAudioUrls.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Audio not available. Check your network."),
                    ),
                  );
                  return;
                }

                if (_isAudioPlaying) {
                  await _audioPlayer.pause();
                } else {
                  await _audioPlayer.play();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Unable to play audio. Check your network."),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemCount: pagedAyahs.length,
                itemBuilder: (context, pageIndex) {
                  return ValueListenableBuilder<int>(
                    valueListenable: currentAyahIndex,
                    builder: (context, highlightedIndex, _) {
                      return _buildPage(
                        pagedAyahs[pageIndex],
                        showBismillah && pageIndex == 0,
                        pageIndex,
                        highlightedIndex,
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              height: 45,
              width: double.infinity,
              color: kprimeryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  "Page ${currentPage + 1} of ${pagedAyahs.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSurahInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFFDF8E8), // matches your app tone
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔶 Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kprimeryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.surah.nameAr,
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.surah.tName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔶 Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _styledInfoRow(
                        "Surah Number",
                        widget.surah.number.toString(),
                      ),
                      _styledInfoRow(
                        "Total Ayahs",
                        widget.ayahs.length.toString(),
                      ),
                      _styledInfoRow("Revelation", widget.surah.revelationType),
                      _styledInfoRow(
                        "Revelation Order",
                        widget.surah.order.toString(),
                      ),
                      _styledInfoRow("Meaning", widget.surah.nameEn),
                    ],
                  ),
                ),

                /// 🔶 Close Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimeryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _styledInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kprimeryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: kprimeryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    List<Ayah> ayahs,
    bool showBismillah,
    int pageIndex,
    int highlightedIndex,
  ) {
    int ayahStartIndex = pageIndex * 7;

    final isTranslationOn =
        widget.translationRepo.translationEnabled &&
        widget.translationRepo.selectedLanguage != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: Color.fromARGB(255, 201, 171, 2), width: 2),
        color: Colors.white,
        // image: DecorationImage(image: AssetImage("assets/images/border1.jpeg")),
      ),

      padding: const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 1),
      child: Column(
        children: [
          if (showBismillah) _buildBismillah(),
          if (showBismillah) const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: isTranslationOn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < ayahs.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                /// Arabic (same highlight logic)
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: ayahs[i].text,
                                        style: TextStyle(
                                          fontSize: 27,
                                          height: 2.4,
                                          fontFamily:
                                              GoogleFonts.amiri().fontFamily,
                                          color:
                                              (_isAudioPlaying &&
                                                  (ayahStartIndex + i) ==
                                                      currentAyahIndex.value)
                                              ? Colors.green
                                              : Colors.black,
                                          fontWeight:
                                              (_isAudioPlaying &&
                                                  (ayahStartIndex + i) ==
                                                      currentAyahIndex.value)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " ﴿${ayahs[i].number}﴾ ",
                                        style: GoogleFonts.amiri(
                                          fontSize: 18,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                ),

                                const SizedBox(height: 6),

                                /// Translation (clean style)
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    widget.translationRepo.getTranslation(
                                          widget.surah.number,
                                          ayahs[i].number - 1,
                                        ) ??
                                        "",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      height: 1.6,
                                      color: Colors.blueGrey,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  /// 🔥 THIS IS YOUR ORIGINAL DESIGN (UNCHANGED)
                  : SelectableText.rich(
                      TextSpan(
                        style: GoogleFonts.amiri(fontSize: 27, height: 2.4),
                        children: [
                          for (int i = 0; i < ayahs.length; i++)
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: ayahs[i].text,
                                  style: GoogleFonts.amiri(
                                    color:
                                        (_isAudioPlaying &&
                                            currentAyahIndex.value >=
                                                ayahStartIndex &&
                                            currentAyahIndex.value <
                                                ayahStartIndex + ayahs.length &&
                                            (ayahStartIndex + i) ==
                                                currentAyahIndex.value)
                                        ? Colors.green
                                        : Colors.black,
                                    fontWeight:
                                        (_isAudioPlaying &&
                                            currentAyahIndex.value >=
                                                ayahStartIndex &&
                                            currentAyahIndex.value <
                                                ayahStartIndex + ayahs.length &&
                                            (ayahStartIndex + i) ==
                                                currentAyahIndex.value)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: " ﴿${ayahs[i].number}﴾ ",
                                  style: GoogleFonts.amiri(
                                    color: Colors.orange,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/smallbroder.png"),
            fit: BoxFit.cover,
          ),
        ),

        // color: const Color(0xFFFDF8E8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 25,
                height: 2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // _buildBismillahDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildBismillahDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFB7935F),
            thickness: 1.5,
            endIndent: 12,
          ),
        ),
        const Icon(Icons.star, size: 18, color: Color(0xFFB7935F)),
        const Expanded(
          child: Divider(color: Color(0xFFB7935F), thickness: 1.5, indent: 12),
        ),
      ],
    );
  }

  List<List<Ayah>> _splitIntoPages(List<Ayah> ayahs) {
    const int ayahsPerPage = 7;
    List<List<Ayah>> pages = [];
    for (int i = 0; i < ayahs.length; i += ayahsPerPage) {
      pages.add(
        ayahs.sublist(
          i,
          i + ayahsPerPage > ayahs.length ? ayahs.length : i + ayahsPerPage,
        ),
      );
    }
    return pages;
  }
}

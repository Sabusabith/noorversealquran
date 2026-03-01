import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:noorversealquran/data/model/ayah_model.dart';
import 'package:noorversealquran/features/home/data/model/surah_model.dart.dart';
import 'package:noorversealquran/features/home/presentation/widgets/menusheet.dart';
import 'package:noorversealquran/features/home/presentation/widgets/reciters.dart';
import 'package:noorversealquran/features/settings/themes.dart';
import 'package:noorversealquran/features/translation_selection/repository/tranlsation_repo.dart';
import 'package:noorversealquran/features/translation_selection/translation_selection_page.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';
import 'package:noorversealquran/utils/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _ayahKeys = [];
  bool _isAudioLoading = false;
  bool _audioInitialized = false;
  bool _isUiVisible = true;
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
    // _enterFullscreen(); // start immersive

    _audioPlayer = AudioPlayer();
    pagedAyahs = _splitIntoPages(widget.ayahs);
    _ayahKeys.addAll(
      List.generate(widget.ayahs.length, (index) => GlobalKey()),
    );

    _loadSavedPage();
    _initialize();

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

  Future<void> _checkIfPageBookmarked() async {
    final bookmarks = await LocalStorage.getBookmarks();

    final exists = bookmarks.any(
      (b) => b['surah'] == widget.surah.number && b['page'] == currentPage,
    );

    if (mounted) {
      setState(() => isSaved = exists);
    }
  }

  Future<void> _initialize() async {
    await GoogleFonts.pendingFonts([GoogleFonts.amiri()]);
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_page_surah_${widget.surah.number}';
    final saved = prefs.getInt(key);
    final startPage = widget.jumpToPage ?? saved ?? 0;

    _pageController = PageController(initialPage: startPage);
    _pageController.addListener(() {
      if (!_isAudioPlaying) return;
      if (!_pageController.hasClients) return;

      final page = _pageController.page;
      if (page == null) return;

      final rounded = page.round();
      final difference = (page - rounded).abs();

      // Only correct very tiny floating drift
      // Ignore real page transitions
      if (difference > 0.0001 && difference < 0.1) {
        _pageController.jumpToPage(rounded);
      }
    });

    setState(() {
      _fontsLoaded = true;
      currentPage = startPage;
    });

    await _checkIfPageBookmarked(); // 👈 ADD THIS LINE
  }

  Future<void> _loadSavedPage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_page_surah_${widget.surah.number}';
    final saved = prefs.getInt(key);

    int startPage = widget.jumpToPage ?? saved ?? 0;

    setState(() {
      currentPage = startPage;
    });
  }

  Future<void> _toggleSavePage() async {
    if (isSaved) {
      await LocalStorage.removeBookmark(widget.surah.number, currentPage);

      setState(() => isSaved = false);

      if (widget.onPageSaved != null) {
        await widget.onPageSaved!(null);
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     backgroundColor: theme.colorScheme.error,
      //     content: Text(
      //       "Bookmark removed",
      //       style: TextStyle(color: theme.colorScheme.onError),
      //     ),
      //     duration: const Duration(seconds: 1),
      //     behavior: SnackBarBehavior.floating,
      //     elevation: 0,
      //   ),
      // );
    } else {
      await LocalStorage.saveBookmark(widget.surah.number, currentPage);

      setState(() => isSaved = true);

      if (widget.onPageSaved != null) {
        await widget.onPageSaved!(currentPage);
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     elevation: 0,
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: theme.colorScheme.primary,
      //     content: Text(
      //       "Bookmark saved",
      //       style: TextStyle(color: theme.colorScheme.onPrimary),
      //     ),
      //     duration: const Duration(seconds: 1),
      //   ),
      // );
    }
  }

  /// Fetch per-Ayah audio URLs using Al-Quran Cloud API
  Future<void> _fetchAyahAudioUrls() async {
    try {
      setState(() => _isAudioLoading = true);

      // get saved reciter
      String reciter = await LocalStorage.getReciter();

      final response = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/surah/${widget.surah.number}/$reciter',
        ),
      );
      if (response.statusCode != 200) throw Exception('Failed to load');

      final data = jsonDecode(response.body);
      final returned = data['data']['edition']['identifier'];
      print('Requested: $reciter | Returned: $returned');
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

  _initAudio() async {
    if (ayahAudioUrls.isEmpty) return;

    try {
      // Start from the first Ayah of the page if jumpToPage is provided
      int startIndex = 0;
      for (int i = 0; i < currentPage; i++) {
        startIndex += pagedAyahs[i].length;
      }
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
        if (!mounted) return;
        if (index != null) {
          currentAyahIndex.value = index;
          if (_isAudioPlaying) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToAyah(index);
            });
          }
          // Auto change page based on Ayah
          int total = 0;
          int newPage = 0;

          for (int i = 0; i < pagedAyahs.length; i++) {
            total += pagedAyahs[i].length;
            if (index < total) {
              newPage = i;
              break;
            }
          }
          if (newPage != currentPage) {
            _pageController.jumpToPage(newPage);
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
      // if (widget.jumpToPage != null) {
      //   await _audioPlayer.play();
      //   setState(() => _isAudioPlaying = true);
      // }
      // If user pressed play while loading
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
    } finally {
      if (mounted) {
        setState(() => _isAudioLoading = false);
      }
    }
  }

  void _showReciterSelection() async {
    final selected = await LocalStorage.getReciter();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.9, // 🔥 Max 90% of screen
          child: Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 25,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                child: Column(
                  children: [
                    /// 🔘 Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    /// 🔤 Title
                    Text(
                      "Select Reciter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// 🔥 Scrollable List
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: reciters.map((reciter) {
                          final isSelected = reciter["code"] == selected;

                          final tileColor = isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHigh;

                          final textColor = isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface;

                          final iconColor = isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant;

                          final borderColor = isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await LocalStorage.saveReciter(reciter["code"]!);

                              _audioInitialized = false;
                              _isAudioPlaying = false;
                              await _audioPlayer.stop();
                              ayahAudioUrls.clear();

                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: tileColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: isSelected ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.record_voice_over,
                                    color: iconColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Text(
                                      reciter["name"]!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ),

                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                    )
                                  else
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReaderMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return ReaderMenuBottomSheet(
          isSaved: isSaved,
          onToggleBookmark: _showSurahInfoDialog,
          onToggleTranslation: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TranslationSelectionPage(
                  translationRepo: widget.translationRepo,
                ),
              ),
            );

            // 🔥 Reload translation when coming back
            await _loadSavedTranslation();
          },
          onSelectReciter: () => _showReciterSelection(),
          onChangeTheme: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Themes()),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    currentAyahIndex.dispose();
    _scrollController.dispose();
    // _exitFullscreen(); // restore system UI

    super.dispose();
  }

  void _updateStatusBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isUiVisible) {
      // 🔹 UI Visible → Match AppBar
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: theme.primaryColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.light,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );
    } else {
      // 🔹 UI Hidden → Also Primary Color
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: theme.primaryColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.light,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (!_fontsLoaded) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: kprimeryColor)),
      );
    }

    final showBismillah = widget.surah.number != 9;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      backgroundColor: _isUiVisible
          ? theme.scaffoldBackgroundColor
          : theme.primaryColor,

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            _isUiVisible = !_isUiVisible;
          });

          _updateStatusBar();
        },
        child: Stack(
          children: [
            /// 🔥 FULL SCREEN PAGEVIEW
            Positioned.fill(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  top: _isUiVisible ? 65 : 0,
                  bottom: _isUiVisible ? 45 : 0,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const ClampingScrollPhysics(),
                      onPageChanged: (index) async {
                        setState(() => currentPage = index);
                        await _checkIfPageBookmarked(); // 👈 add this line
                      },
                      itemCount: pagedAyahs.length,
                      itemBuilder: (context, pageIndex) {
                        return ValueListenableBuilder<int>(
                          valueListenable: currentAyahIndex,
                          builder: (context, highlightedIndex, _) {
                            return _buildPage(
                              _isUiVisible,
                              widget.surah.nameAr,
                              widget.surah.tName,
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
                ),
              ),
            ),

            /// 🔥 TOP APP BAR OVERLAY
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: _isUiVisible ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                height: 90,
                color: theme.primaryColor,
                child: SafeArea(
                  bottom: false,
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
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
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.surah.nameAr,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.surah.tName,
                          style: GoogleFonts.publicSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onPrimary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Transform(
                        transform: Matrix4.translationValues(14, 0, 0),
                        child: IconButton(
                          icon: isSaved
                              ? Icon(
                                  Icons.bookmark,
                                  color: !isSaved
                                      ? theme.colorScheme.onPrimary
                                      : Colors.red,
                                  size: 19,
                                )
                              : Icon(Icons.bookmark_border, size: 19),
                          onPressed: _toggleSavePage,
                        ),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(10, 0, 0),
                        child: IconButton(
                          onPressed: () async {
                            if (_isAudioLoading) return;

                            // If audio not prepared yet
                            if (!_audioInitialized) {
                              setState(() => _isAudioLoading = true);
                              // 🔥 Always seek to current page before playing
                              int newIndex = 0;
                              for (int i = 0; i < currentPage; i++) {
                                newIndex += pagedAyahs[i].length;
                              }
                              if (newIndex < ayahAudioUrls.length) {
                                await _audioPlayer.seek(
                                  Duration.zero,
                                  index: newIndex,
                                );
                              }

                              try {
                                await _fetchAyahAudioUrls();
                                await _initAudio();
                                _audioInitialized = true;
                                await _audioPlayer.play();
                              } catch (_) {}

                              if (mounted) {
                                setState(() => _isAudioLoading = false);
                              }

                              return;
                            }

                            // If already initialized
                            if (_isAudioPlaying) {
                              await _audioPlayer.pause();
                            } else {
                              // 🔥 Calculate correct start index for current page
                              int pageStartIndex = 0;
                              for (int i = 0; i < currentPage; i++) {
                                pageStartIndex += pagedAyahs[i].length;
                              }

                              final currentIndex =
                                  _audioPlayer.currentIndex ?? 0;

                              // 🔥 If paused index is NOT inside current page → seek
                              int pageEndIndex =
                                  pageStartIndex +
                                  pagedAyahs[currentPage].length;

                              if (currentIndex < pageStartIndex ||
                                  currentIndex >= pageEndIndex) {
                                await _audioPlayer.seek(
                                  Duration.zero,
                                  index: pageStartIndex,
                                );
                              }

                              await _audioPlayer.play();
                            }
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isAudioLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Icon(
                                    _isAudioPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 22,
                                    color: _isAudioPlaying
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onPrimary,
                          size: 22,
                        ),
                        onPressed: _showReaderMenu,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔥 BOTTOM PAGE INDICATOR OVERLAY
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: _isUiVisible
                  ? 0
                  : -(45 + MediaQuery.of(context).padding.bottom),
              left: 0,
              right: 0,
              child: Container(
                height: 45 + MediaQuery.of(context).padding.bottom,
                color: theme.primaryColor,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Center(
                    child: Text(
                      "Page ${currentPage + 1} of ${pagedAyahs.length}",
                      style: GoogleFonts.publicSans(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.20)
        : theme.colorScheme.primary.withOpacity(0.20);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.dialogBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔶 Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
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
                          color: theme.colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.surah.tName,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.85),
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
                      backgroundColor: bgColor,
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

  void _scrollToAyah(int globalIndex) {
    final isTranslationOn =
        widget.translationRepo.translationEnabled &&
        widget.translationRepo.selectedLanguage != null;

    // -----------------------------
    // 🔹 TRANSLATION MODE (Perfect)
    // -----------------------------
    if (isTranslationOn) {
      if (globalIndex < 0 || globalIndex >= _ayahKeys.length) return;

      final context = _ayahKeys[globalIndex].currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
      return;
    }

    // ---------------------------------
    // 🔥 PARAGRAPH MODE (Pixel Perfect)
    // ---------------------------------

    final int pageStartIndex = currentPage * 7;
    final int localIndex = globalIndex - pageStartIndex;

    if (localIndex < 0 || localIndex >= pagedAyahs[currentPage].length) return;

    final currentPageAyahs = pagedAyahs[currentPage];

    // Build paragraph EXACTLY like RichText
    final List<InlineSpan> spans = [];
    for (int i = 0; i < currentPageAyahs.length; i++) {
      spans.add(
        TextSpan(
          text: currentPageAyahs[i].text,
          style: GoogleFonts.amiri(fontSize: 27, height: 2.4),
        ),
      );
      spans.add(
        TextSpan(
          text: " ﴿${currentPageAyahs[i].number}﴾ ",
          style: GoogleFonts.amiri(fontSize: 20, height: 2.4),
        ),
      );
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );

    final double maxWidth = MediaQuery.of(context).size.width - 50;
    textPainter.layout(maxWidth: maxWidth);

    // Calculate character offset before target ayah
    int charOffset = 0;
    for (int i = 0; i < localIndex; i++) {
      charOffset += currentPageAyahs[i].text.length;
      charOffset += " ﴿${currentPageAyahs[i].number}﴾ ".length;
    }

    final Offset caretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: charOffset),
      Rect.zero,
    );

    if (_scrollController.hasClients) {
      final targetOffset = (caretOffset.dy - 80).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      final currentOffset = _scrollController.offset;
      final difference = (targetOffset - currentOffset).abs();

      // Only animate if movement is noticeable
      if (difference > 20) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _styledInfoRow(String title, String value) {
    final theme = Theme.of(context);

    // Decide background and text color based on brightness
    final bool isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.12)
        : theme.colorScheme.primary.withOpacity(0.12);

    final Color textColor = isDark
        ? theme
              .colorScheme
              .onSurface // white-ish
        : theme.colorScheme.primary; // colored

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Title
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          /// Value Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: textColor.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    bool isvisible,
    String surah,
    String surahEn,
    List<Ayah> ayahs,
    bool showBismillah,
    int pageIndex,
    int highlightedIndex,
  ) {
    final theme = Theme.of(context);

    int ayahStartIndex = 0;
    for (int i = 0; i < pageIndex; i++) {
      ayahStartIndex += pagedAyahs[i].length;
    }

    final isTranslationOn =
        widget.translationRepo.translationEnabled &&
        widget.translationRepo.selectedLanguage != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: theme.scaffoldBackgroundColor,
      ),
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 1),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: isTranslationOn
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBismillah) _buildBismillah(),
                  if (showBismillah) const SizedBox(height: 20),
                  if (!isvisible && !showBismillah) const SizedBox(height: 15),
                  if (!isvisible && !showBismillah)
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Text(
                        "$surah $surahEn",
                        style: GoogleFonts.scheherazadeNew(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (!isvisible && !showBismillah) const SizedBox(height: 20),

                  /// ===============================
                  /// TRANSLATION MODE
                  /// ===============================
                  for (int i = 0; i < ayahs.length; i++) ...[
                    Builder(
                      builder: (context) {
                        bool isCurrentAyah =
                            _isAudioPlaying &&
                            (ayahStartIndex + i) == currentAyahIndex.value;

                        return Container(
                          key: _ayahKeys[ayahStartIndex + i],
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          decoration: BoxDecoration(
                            color: isCurrentAyah
                                ? theme.colorScheme.secondary.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              /// Arabic
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: ayahs[i].text,
                                      style: TextStyle(
                                        fontSize: 24,
                                        height: 2.4,
                                        fontFamily: 'KFGQPCUthmanic',
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: isCurrentAyah
                                            ? FontWeight.bold
                                            : FontWeight.w300,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " ﴿${ayahs[i].number}﴾ ",
                                      style: GoogleFonts.amiri(
                                        fontSize: 18,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                                textDirection: TextDirection.rtl,
                              ),

                              const SizedBox(height: 6),

                              /// Translation
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  widget.translationRepo.getTranslation(
                                        widget.surah.number,
                                        ayahs[i].number - 1,
                                      ) ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: isCurrentAyah
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(color: theme.dividerColor, thickness: .5),
                  ],
                ],
              )
            /// ===============================
            /// NON TRANSLATION MODE
            /// ===============================
            : Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Column(
                  children: [
                    if (showBismillah) _buildBismillah(),
                    if (showBismillah) const SizedBox(height: 20),
                    if (!isvisible && !showBismillah)
                      const SizedBox(height: 15),
                    if (!isvisible && !showBismillah)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "$surah $surahEn",
                            style: GoogleFonts.scheherazadeNew(
                              color: theme.colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    if (!isvisible && !showBismillah)
                      const SizedBox(height: 20),

                    RichText(
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'KFGQPCUthmanic',
                          fontSize: 24,
                          height: 2.4,
                        ),
                        children: [
                          for (int i = 0; i < ayahs.length; i++) ...[
                            TextSpan(
                              text: ayahs[i].text,
                              style: TextStyle(
                                backgroundColor:
                                    (_isAudioPlaying &&
                                        (ayahStartIndex + i) ==
                                            currentAyahIndex.value)
                                    ? theme.colorScheme.secondary.withOpacity(
                                        0.25,
                                      )
                                    : Colors.transparent,
                                fontFamily: 'KFGQPCUthmanic',
                                color:
                                    (_isAudioPlaying &&
                                        (ayahStartIndex + i) ==
                                            currentAyahIndex.value)
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface,
                                fontWeight:
                                    (_isAudioPlaying &&
                                        (ayahStartIndex + i) ==
                                            currentAyahIndex.value)
                                    ? FontWeight.bold
                                    : FontWeight.w300,
                              ),
                            ),

                            /// Ayah Number — ALWAYS Accent Color
                            TextSpan(
                              text: " ﴿${ayahs[i].number}﴾ ",
                              style: GoogleFonts.amiri(
                                color: theme.colorScheme.secondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBismillah() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.35),
              blurRadius: 20, // softness
              spreadRadius: 5, // how much it spreads outward
              offset: const Offset(0, 8), // vertical shadow
            ),
          ],
          // color: theme.primaryColor,
          image: const DecorationImage(
            image: AssetImage("assets/images/smallbroder.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'KFGQPCUthmanic',
                  fontSize: 25,
                  height: 2,

                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
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

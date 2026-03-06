import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class PrayerVideoPage extends StatefulWidget {
  final String title;
  final String url;

  const PrayerVideoPage({super.key, required this.title, required this.url});

  @override
  State<PrayerVideoPage> createState() => _PrayerVideoPageState();
}

class _PrayerVideoPageState extends State<PrayerVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.url)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
    _controller.addListener(() {
      if (!_controller.value.isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {},
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _controller.value.isFullScreen
              ? null
              : AppBar(
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
          body: Center(child: player),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class DigitalTasbihPage extends StatefulWidget {
  const DigitalTasbihPage({super.key});

  @override
  State<DigitalTasbihPage> createState() => _DigitalTasbihPageState();
}

class _DigitalTasbihPageState extends State<DigitalTasbihPage>
    with SingleTickerProviderStateMixin {
  int _count = 0;

  Map<String, String> _selectedDua = {
    "arabic": "Select Dua",
    "english": "",
    "meaning": "",
  };

  final List<Map<String, String>> _duas = [
    {
      "arabic": "سبحان الله",
      "english": "SubhanAllah",
      "meaning": "Glory be to Allah",
    },
    {
      "arabic": "الْحَمْدُ لِلّهِ",
      "english": "Alhamdulillah",
      "meaning": "All praise be to Allah",
    },
    {
      "arabic": "اللهُ أَكْبَر",
      "english": "Allahu Akbar",
      "meaning": "Allah is the Greatest",
    },
    {
      "arabic": "لَا إِلٰهَ إِلَّا الله",
      "english": "La ilaha illallah",
      "meaning": "There is no god but Allah",
    },
    {
      "arabic": "أَسْتَغْفِرُ الله",
      "english": "Astaghfirullah",
      "meaning": "I seek forgiveness from Allah",
    },
    {
      "arabic": "لا حول ولا قوة إلا بالل",
      "english": "La hawla wa la quwwata illa billah",
      "meaning": "There is no power except with Allah",
    },
  ];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
    });
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) Vibration.vibrate(duration: 20);
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _showDuaBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Indicator
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Select Dua",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 400,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _duas.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final dua = _duas[index];
                      final isSelected =
                          _selectedDua['arabic'] == dua['arabic'];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.secondary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            dua['arabic'] ?? '',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'ScheherazadeNew',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "${dua['english']} • ${dua['meaning']}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.secondary,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedDua = dua;
                              _count = 0;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: GestureDetector(
          onTap: _reset,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Icon(Icons.refresh, size: 28, color: Colors.white),
          ),
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 60,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: theme.colorScheme.onPrimary,
            size: 16,
          ),
        ),
        title: Text("Digital Tasbih", style: GoogleFonts.poppins(fontSize: 18)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.9),
              theme.primaryColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dua Selector
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showDuaBottomSheet(theme),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _selectedDua['arabic'] ?? "Tap to Select Dua ",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontFamily: 'ScheherazadeNew',
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        if (_selectedDua['arabic'] == "Select Dua")
                          TextSpan(
                            text: "👆🏻",
                            style: TextStyle(
                              fontSize: 22, // no fontFamily here!
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if ((_selectedDua['english'] ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${_selectedDua['english']} - ${_selectedDua['meaning']}",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 50),

            // Counter
            Text(
              '$_count',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 40),

            // Animated Tasbih Button
            ScaleTransition(
              scale: _pulseController,
              child: GestureDetector(
                onTap: _increment,
                onLongPress: () => _increment(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary.withOpacity(0.7),
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

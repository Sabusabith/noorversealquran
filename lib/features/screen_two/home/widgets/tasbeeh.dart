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

  void _showDuaDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with accent line
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Select Dua",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _duas.length,
                  itemBuilder: (context, index) {
                    final dua = _duas[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: theme.cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          "${dua['arabic']} • ${dua['english']}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        onTap: () {
                          setState(() {
                            _selectedDua = dua;
                            _count = 0;
                          });
                          Navigator.pop(context);
                        },
                        trailing: Icon(
                          Icons.check_circle_outline,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
            GestureDetector(
              onTap: () => _showDuaDialog(theme),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _selectedDua['arabic'] ?? "Select Dua",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.onPrimary,
                          size: 30,
                        ),
                      ],
                    ),
                    if ((_selectedDua['english'] ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${_selectedDua['english']} - ${_selectedDua['meaning']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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

            // Reset Button
            ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              child: const Icon(Icons.refresh, size: 28, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

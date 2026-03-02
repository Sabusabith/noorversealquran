import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noorversealquran/features/screen_two/core/names_model.dart';
import 'package:http/http.dart' as http;

class AllahNamesPage extends StatefulWidget {
  const AllahNamesPage({super.key});

  @override
  State<AllahNamesPage> createState() => _AllahNamesPageState();
}

class _AllahNamesPageState extends State<AllahNamesPage> {
  List<AllahName> names = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNames();
  }

  Future<void> loadNames() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://api.aladhan.com/v1/asmaAlHusna'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        setState(() {
          names = data.map((e) => AllahName.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Server error");
      }
    } on SocketException {
      setState(() {
        errorMessage = "No Internet Connection";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
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
        toolbarHeight: 80,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Asma ul Husna",
              style: TextStyle(
                fontFamily: 'KFGQPCUthmanic',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The 99 Beautiful Names of Allah",
              style: GoogleFonts.poppins(
                color: colors.onPrimary.withOpacity(0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(colors, theme, isDark),
    );
  }

  Widget _buildBody(ColorScheme colors, ThemeData theme, bool isDark) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 60, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16, color: colors.onSurface),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loadNames, child: const Text("Retry")),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final item = names[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: colors.outline.withOpacity(isDark ? 0.6 : 0.3),
            ),
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? colors.surface.withOpacity(0.95)
                : colors.surfaceVariant,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: colors.primaryContainer,
                  ),
                  child: Text(
                    "${item.number}",
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Arabic Name
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'KFGQPCUthmanic',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: isDark ? colors.onSurface : colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                // Transliteration
                Text(
                  item.transliteration,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? colors.onSurface.withOpacity(0.9)
                        : colors.onSurface.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 14),

                Divider(color: colors.outline.withOpacity(isDark ? 0.6 : 0.3)),

                const SizedBox(height: 14),

                // Meaning
                Text(
                  item.meaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? colors.onSurface
                        : colors.onSurface.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:noorversealquran/features/settings/themes.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 24),
          _AppearanceSection(),
          SizedBox(height: 24),
          // _ReadingSection(),
          // SizedBox(height: 24),
          // _NotificationSection(),
          // SizedBox(height: 24),
          // _LanguageSection(),
          // SizedBox(height: 24),
          // _AboutSection(),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// APPEARANCE SECTION
////////////////////////////////////////////////////////////

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return _themeTile(context, 'Themes');
  }

  Widget _themeTile(BuildContext context, String title) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),

        leading: Icon(Icons.color_lens),
        trailing: Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => themes()),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// QURAN READING SECTION
////////////////////////////////////////////////////////////

class _ReadingSection extends StatelessWidget {
  const _ReadingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Quran Reading"),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text("Show Translation"),
          value: true,
          onChanged: (value) {},
        ),
        ListTile(
          title: const Text("Arabic Font Size"),
          subtitle: const Text("Adjust reading size"),
          trailing: Icon(Icons.chevron_right, color: kprimeryColor),
          onTap: () {},
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// NOTIFICATION SECTION
////////////////////////////////////////////////////////////

class _NotificationSection extends StatelessWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Reminders"),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text("Daily Ayah Reminder"),
          value: false,
          onChanged: (value) {},
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// LANGUAGE SECTION
////////////////////////////////////////////////////////////

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Language"),
        const SizedBox(height: 12),
        ListTile(
          title: const Text("App Language"),
          subtitle: const Text("English"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// ABOUT SECTION
////////////////////////////////////////////////////////////

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("About"),
        const SizedBox(height: 12),
        ListTile(
          title: const Text("About NoorVerse"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          title: const Text("Privacy Policy"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          title: const Text("Rate App"),
          trailing: const Icon(Icons.star_border),
          onTap: () {},
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// SECTION TITLE WIDGET
////////////////////////////////////////////////////////////

Widget _sectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}

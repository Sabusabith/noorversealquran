import 'package:flutter/material.dart';
import 'package:noorversealquran/features/home/presentation/home.dart';
import 'package:noorversealquran/features/screen_two/home/screen_two_home.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [Home(), ListPage()];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: NavigationBar(
        indicatorShape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        height: 65,

        backgroundColor: theme.colorScheme.primary,
        indicatorColor: theme.colorScheme.onPrimary.withOpacity(0.80),
        selectedIndex: _currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,

        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },

        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
            ),
            selectedIcon: Icon(
              Icons.menu_book,
              color: theme.colorScheme.primary,
            ),
            label: "",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.grid_view_outlined,
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
            ),
            selectedIcon: Icon(
              Icons.grid_view,
              color: theme.colorScheme.primary,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class GardenHomeScreen extends StatefulWidget {
  const GardenHomeScreen({super.key});

  @override
  State<GardenHomeScreen> createState() => _GardenHomeScreenState();
}

class _GardenHomeScreenState extends State<GardenHomeScreen> {
  // Tracks which bottom navigation tab is selected.
  int _selectedIndex = 0;
  //Three main selection of widgets for app (on bottom nav bar)
  final List<Widget> _screens = const [
    _GardenDashboard(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      // Navigation bar to navigate between screens
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          // sets the state of the tab, rebuilds the screen based on selection
          setState(() {
            _selectedIndex = index;
          });
        },
        //nav bar destonations (widgets at bottom)
        destinations: [
          NavigationDestination(
            //using personal icon pngs instead of built-ins
             icon: Image.asset(
              'assets/images/home-icon.png',
              width: 64,
              height: 64,
            ),
            selectedIcon: Image.asset(
              'assets/images/home-icon.png',
              width: 64,
              height: 64,
            ),
            label: 'Garden',
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/images/history-icon.png',
              width: 64,
              height: 64,
            ),
            selectedIcon: Image.asset(
              'assets/images/history-icon.png',
              width: 64,
              height: 64,
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/images/settings-icon.png',
              width: 64,
              height: 64,
            ),
            selectedIcon: Image.asset(
              'assets/images/settings-icon.png',
              width: 64,
              height: 64,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _GardenDashboard extends StatelessWidget {
  const _GardenDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Secret Garden'),
      ),
      body: const Center(
        child: Text('Your garden is waiting to grow.'),
      ),
    );
  }
}

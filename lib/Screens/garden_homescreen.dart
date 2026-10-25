
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
        indicatorColor: const Color.fromARGB(255, 218, 214, 206),
        backgroundColor: const Color(0xFFF3EFE6),
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
        //nav bar destinations (widgets at bottom)
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

//main dashboard (display)
class _GardenDashboard extends StatelessWidget {
  const _GardenDashboard();
  //settings button on top right corner
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EFE6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/app-icon.png',
          ),
        ),
        title: const Text('Habit Secret Garden'),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/settings-icon.png',
              width: 56,
              height: 56,
            ),
            tooltip: 'Settings',
            onPressed: () {
              // Settings navigation will be connected next.
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weekly completion widget
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2D9C9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Completion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '0%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Keep up your habits and watch your secret garden grow!'),
                  // progress bar connexted to percent calculation
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      minHeight: 10,
                      backgroundColor: Color(0xFFDAD2C3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF547653),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //drop-down menu to filter habits and add habit button
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: 'All Habits',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF3EFE6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'All Habits',
                        child: Text('All Habits'),
                      ),
                      DropdownMenuItem(
                        value: 'Favorites',
                        child: Text('Favorites'),
                      ),
                      DropdownMenuItem(
                        value: 'Health',
                        child: Text('Health'),
                      ),
                      DropdownMenuItem(
                        value: 'Personal Growth',
                        child: Text('Personal Growth'),
                      ),
                      DropdownMenuItem(
                        value: 'Productivity',
                        child: Text('Productivity'),
                      ),
                    ],
                    onChanged: (String? value) {
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Habit creation screen will be connected later.
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add Habit',
                      style: TextStyle(fontSize:18),
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF547653),
                      foregroundColor: const Color(0xFFF3EFE6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

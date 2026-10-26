
import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'create_habit.dart';

class GardenHomeScreen extends StatefulWidget {
  const GardenHomeScreen({super.key});

  @override
  State<GardenHomeScreen> createState() => _GardenHomeScreenState();
}

class _GardenHomeScreenState extends State<GardenHomeScreen> {
  // Tracks which bottom navigation tab is selected.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _GardenDashboard(
        onSettingsPressed: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      const HistoryScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
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
  final VoidCallback onSettingsPressed;

  const _GardenDashboard({
    required this.onSettingsPressed,
  });
  //settings button on top right corner
  @override
  Widget build(BuildContext context) {
    const bool hasHabits = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EFE6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            'assets/images/app-icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        title: const Text('Habit Secret Garden'),
        //special code for settings icon sizing**
        actions: [
          IconButton(
            constraints: const BoxConstraints(
              minWidth: 64,
              minHeight: 64,
            ),
            padding: const EdgeInsets.all(4),
            icon: Image.asset(
              'assets/images/settings-icon.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
            tooltip: 'Settings',
            onPressed: onSettingsPressed,
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
                  Text(
                    'Keep up your habits and watch your secret garden grow!',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
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
            if (hasHabits) ...[
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
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateHabitScreen(),
                      ),
                    ); 
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add Habit',
                      style: TextStyle(fontSize:18),
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 63, 161, 84),
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
            // EMPTY SCREEN STATE: NO HABITS PLANTED YET!
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  const Spacer(),

                  Image.asset(
                    'assets/images/empty-garden.png',
                    width: 260,
                    height: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Your garden is empty!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Add your first habit to start growing your garden.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateHabitScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text(
                        'Add Habit',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 63, 161, 84),
                        foregroundColor: const Color(0xFFF3EFE6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}

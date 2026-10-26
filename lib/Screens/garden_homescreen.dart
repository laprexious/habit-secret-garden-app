
import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'create_habit.dart';
import '../database/habit_database.dart';

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
        indicatorColor: const Color.fromARGB(255, 206, 202, 196),
        backgroundColor: const Color.fromARGB(255, 240, 232, 213),
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
class _GardenDashboard extends StatefulWidget {
  final VoidCallback onSettingsPressed;

  const _GardenDashboard({
    required this.onSettingsPressed,
  });

  @override
  State<_GardenDashboard> createState() => _GardenDashboardState();
}

class _GardenDashboardState extends State<_GardenDashboard> {
  late Future<Map<String, dynamic>> _dashboardFuture;
  String _selectedFilter = 'All Habits';

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  void _loadHabits() {
    _dashboardFuture = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final habits = await HabitDatabase.instance.getHabits();
    final checkInCounts =
        await HabitDatabase.instance.getWeeklyCheckInCounts();

    return {
      'habits': habits,
      'checkInCounts': checkInCounts,
    };
  }
  //PLANT PROGRESSION IMAGE CALCULATION AND THRESHOLDS
  String _getProgressionImage(int completedCheckIns, int weeklyTarget, String iconPath) {
    final percentage = weeklyTarget == 0
        ? 0
        : (completedCheckIns / weeklyTarget * 100).round();

    if (percentage <= 25) {
      return 'assets/images/sprout.png';
    } else if (percentage <= 50) {
      return 'assets/images/growing.png';
    } else if (percentage <= 75) {
      return 'assets/images/thriving.png';
    } else {
      return iconPath;
    }
  }

  Future<void> _addHabit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateHabitScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _loadHabits();
    });
  }

  //settings button on top right corner
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final dashboardData = snapshot.data;
        final habits =
            dashboardData?['habits'] as List<Map<String, dynamic>>? ?? [];
        final checkInCounts =
            dashboardData?['checkInCounts'] as Map<int, int>? ?? {};

        final categories = habits
            .map((habit) => habit['category'] as String)
            .toSet()
            .toList()
          ..sort();

        final displayedHabits = _selectedFilter == 'All Habits'
            ? habits
            : habits.where((habit) {
                return habit['category'] == _selectedFilter;
              }).toList();

        final hasHabits = habits.isNotEmpty;

        //need to add in completion bar connection
        final totalTarget = habits.fold<int>(
          0,
          (sum, habit) => sum + (habit['weeklyTarget'] as int),
        );

        final totalCompleted = habits.fold<int>(
          0,
          (sum, habit) {
            final habitId = habit['id'] as int;
            final target = habit['weeklyTarget'] as int;
            final completed = checkInCounts[habitId] ?? 0;

            return sum + completed.clamp(0, target);
          },
        );

final weeklyProgress =
    totalTarget == 0 ? 0.0 : totalCompleted / totalTarget;

final weeklyPercentage = (weeklyProgress * 100).round();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 240, 232, 213),
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
                onPressed: widget.onSettingsPressed,
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
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '$weeklyPercentage%',
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
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: weeklyProgress),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: value,
                                        minHeight: 16,
                                        backgroundColor: const Color(0xFFDAD2C3),
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Color.fromARGB(255, 70, 139, 68),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: (constraints.maxWidth - 12) * value,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF547653),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color.fromARGB(255, 157, 235, 177),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                          value: _selectedFilter,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'All Habits',
                              child: Text('All Habits'),
                            ),
                            const DropdownMenuItem(
                              value: 'Favorites',
                              child: Text('Favorites'),
                            ),
                            ...categories.map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            if (value == null) return;

                            setState(() {
                              _selectedFilter = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _addHabit,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Add Habit',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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
                // GRID VIEW OF HABITS DISPLAY
                const SizedBox(height: 20),
                Expanded(
                  child: hasHabits
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: displayedHabits.length,
                          itemBuilder: (context, index) {
                            final habit = displayedHabits[index];
                            // update card fraction
                            final habitId = habit['id'] as int;
                            final completedCheckIns =
                                checkInCounts[habitId] ?? 0;
                            // Card UI and details
                            return Card(
                              color: const Color.fromARGB(195, 223, 203, 158),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 57, 112, 59),
                                  width: 0.8,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      habit['name'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$completedCheckIns/${habit['weeklyTarget']}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    Image.asset(
                                      _getProgressionImage(
                                        completedCheckIns,
                                        habit['weeklyTarget'] as int,
                                        habit['iconPath'] as String,
                                      ),
                                      width: 104,
                                      height: 104,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      //EDGE CASE: EMPTY GARDEN
                      : Column(
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
                              style: TextStyle(fontSize: 18),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ElevatedButton.icon(
                                onPressed: _addHabit,
                                icon: const Icon(Icons.add, size: 24),
                                label: const Text(
                                  'Add Habit',
                                  style: TextStyle(fontSize: 20),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF547653),
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
      },
    );
  }
}

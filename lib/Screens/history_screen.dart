import 'package:flutter/material.dart';
import '../database/habit_database.dart';

// initialize/ load as stateful
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

// screen main build 
class _HistoryScreenState extends State<HistoryScreen> {
    late Future<Map<String, dynamic>> _historyFuture;
    final ScrollController _scrollController = ScrollController();
    @override
    void initState() {
      super.initState();
      _historyFuture = _loadHistoryData();
    }
// load history sql
    Future<Map<String, dynamic>> _loadHistoryData() async {
      final habits = await HabitDatabase.instance.getHabits();
      final checkInCounts =
          await HabitDatabase.instance.getWeeklyCheckInCounts();
      final checkIns =
          await HabitDatabase.instance.getRecentCheckIns();
      return {
        'habits': habits,
        'checkInCounts': checkInCounts,
        'checkIns': checkIns,
      };
    }
  @override
  // same initial build as first two screens: 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text('History & Insights'),
      ),
      // app body build
      body: FutureBuilder<Map<String, dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load your history.'),
            );
          }
          final data = snapshot.data!;
          final habits = data['habits'] as List<Map<String, dynamic>>;
          final checkInCounts = data['checkInCounts'] as Map<int, int>;
          final checkIns = data['checkIns'] as List<Map<String, dynamic>>;

          // Weekly completion calculation (used from homescreen): 
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Weekly Completion card card UI and % (modeled using homescreen)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2D9C9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Completion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF547653),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$weeklyPercentage%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // smooth animation for bar progress
                          Expanded(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: weeklyProgress,
                              ),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  minHeight: 16,
                                  backgroundColor: const Color(0xFFDAD2C3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 70, 139, 68),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent Check-ins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // set box size for scrolling and view of insights 
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 235, 232),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD5CEC1),
                        width: 3,
                      ),
                    ),
                    // edge case:
                    child: checkIns.isEmpty
                      ? const Center(
                          child: Text('No check-ins yet.'),
                        )
                        // visual scroll to help user interaction
                      : Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: ListView.builder(
                            itemCount: checkIns.length,
                            itemBuilder: (context, index) {
                              final checkIn = checkIns[index];
                              // list card ui
                              return Card(
                                color: const Color(0xFFE2D9C9),
                                child: ListTile(
                                  leading: Image.asset('assets/images/filled-leaf.png'),
                                  title: Text(
                                    checkIn['checkInDate'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Image.asset('assets/images/edit-icon.png'),
                                        // edit button logic to change date
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: Image.asset('assets/images/delete-icon.png'),
                                        // delete button logic to delete from history
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

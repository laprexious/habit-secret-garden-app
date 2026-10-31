
import 'package:flutter/material.dart';
import '../database/habit_database.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> habit;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late Future<Map<int, int>> _checkInFuture;
  late Future<List<String>> _checkInDatesFuture;

  @override
  void initState() {
    super.initState();
    _checkInFuture = HabitDatabase.instance.getWeeklyCheckInCounts();
    _checkInDatesFuture =
        HabitDatabase.instance.getCheckInDatesForHabit(
      widget.habit['id'] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final weeklyTarget = habit['weeklyTarget'] as int;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 232, 213),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 232, 213),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back-icon.png',
            width: 54,
            height: 54,
          ),
          tooltip: 'Back to Garden',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Habit Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A8683),
                side: const BorderSide(
                  color: Color(0xFF4A8683),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    //screen body
      body: FutureBuilder<Map<int, int>>(
        future: _checkInFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load habit progress.'),
            );
          }

          final habitId = habit['id'] as int;
          final completed = snapshot.data?[habitId] ?? 0;
          final progress = weeklyTarget > 0
              ? (completed / weeklyTarget).clamp(0.0, 1.0)
              : 0.0;

          final plantImage = progress <= 0.25
              ? 'assets/images/sprout.png'
              : progress <= 0.50
                  ? 'assets/images/growing.png'
                  : progress <= 0.75
                      ? 'assets/images/thriving.png'
                      : habit['iconPath'] as String;
          //scroll access
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      habit['iconPath'] as String,
                      width: 76,
                      height: 76,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  habit['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (habit['isFavorite'] == 1) ...[
                                const SizedBox(width: 6),
                                Image.asset(
                                  'assets/images/favorite-star.png',
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '(Favorite)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF547653),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECC1C1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              habit['category'] as String,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(175, 231, 211, 163),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        plantImage,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completed of $weeklyTarget check-ins this week',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: const Color(0xFFDAD2C3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF547653),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Check in for today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await HabitDatabase.instance.addCheckIn(
                        habit['id'] as int,
                        DateTime.now(),
                      );

                      if (!mounted) return;
                      setState(() {
                        _checkInFuture = HabitDatabase.instance.getWeeklyCheckInCounts();
                        _checkInDatesFuture =
                            HabitDatabase.instance.getCheckInDatesForHabit(
                          habit['id'] as int,
                        );
                      });

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result == 0
                                ? 'Already checked in today!'
                                : 'Check-in saved!',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Check In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // reset, finish, delete requirements:
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/favorite-star.png',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(height: 8),
                            const Text('Finish'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/reset-button.png',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(height: 8),
                            const Text('Reset'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/trash-bin.png',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(height: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'This Week',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<String>>(
                  future: _checkInDatesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Text('Unable to load check-ins.');
                    }

                    final checkInDates = snapshot.data ?? [];
                    final today = DateTime.now();
                    final weekStart = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    ).subtract(Duration(days: today.weekday - 1));

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 7; i++)
                          Column(
                            children: [
                              Image.asset(
                                checkInDates.contains(
                                  '${weekStart.add(Duration(days: i)).year.toString().padLeft(4, '0')}-'
                                  '${weekStart.add(Duration(days: i)).month.toString().padLeft(2, '0')}-'
                                  '${weekStart.add(Duration(days: i)).day.toString().padLeft(2, '0')}',
                                )
                                    ? 'assets/images/filled-leaf.png'
                                    : 'assets/images/unfilled-leaf.png',
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


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
      body: const Center(
        child: Text('Create your new habit here.'),
      ),
    );
  }
}

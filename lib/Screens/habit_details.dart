
import 'package:flutter/material.dart';
import '../database/habit_database.dart';
import 'create_habit.dart';

// REQUIRED AI HELPER:
Map<String, dynamic>? calculateGardenGuideSuggestion({
  required List<String> checkInDates,
  required String startedLocalDate,
  required DateTime asOfDate,
}) {
  final startedDate = DateTime.parse(startedLocalDate);
  final currentWeekStart = DateTime(
    asOfDate.year,
    asOfDate.month,
    asOfDate.day - (asOfDate.weekday - 1),
  );
  final firstWeekStart = DateTime(
    currentWeekStart.year,
    currentWeekStart.month,
    currentWeekStart.day - 21,
  );
  final firstEligibleWeek = startedDate.weekday == DateTime.monday
      ? DateTime(startedDate.year, startedDate.month, startedDate.day)
      : DateTime(
          startedDate.year,
          startedDate.month,
          startedDate.day,
        ).subtract(Duration(days: startedDate.weekday - 1))
          .add(const Duration(days: 7));

  if (firstEligibleWeek.isAfter(firstWeekStart)) {
    return null;
  }

  final uniqueDates = checkInDates.toSet();
  final weekCounts = <int>[];

  for (int i = 0; i < 3; i++) {
    final weekStart = firstWeekStart.add(Duration(days: i * 7));
    final weekEnd = weekStart.add(const Duration(days: 7));
    //normalize before comparison: change needed for helper
    final count = uniqueDates.where((dateString) {
      final date = DateTime.parse(dateString);
      final checkInDay = DateTime(date.year, date.month, date.day);

      return !checkInDay.isBefore(weekStart) &&
          checkInDay.isBefore(weekEnd) &&
          !checkInDay.isBefore(startedDate);
    }).length;

    if (count > 7) {
      throw FormatException('Invalid weekly check-in count.');
    }

    weekCounts.add(count);
  }

  final average = weekCounts.reduce((a, b) => a + b) / 3;

  return {
    'weekCounts': weekCounts,
    'average': average,
    'suggestedTarget': average.round().clamp(1, 7),
  };
}

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
  late Map<String, dynamic> _habit;
  Map<String, dynamic>? _gardenGuideSuggestion;
  String? _gardenGuideChoice;

  @override
  void initState() {
    super.initState();
    _habit = Map<String, dynamic>.from(widget.habit);
    _checkInFuture = HabitDatabase.instance.getWeeklyCheckInCounts();
    _checkInDatesFuture =
        HabitDatabase.instance.getCheckInDatesForHabit(
      widget.habit['id'] as int,
    );
    _loadGardenGuide();
  }
  // METHOD FOR AI HELPER: LOADS habit dates to pass to helper
  Future<void> _loadGardenGuide() async {
    final startedDate = _habit['startedLocalDate'];

    if (startedDate == null) return;

    final checkInDates =
        await HabitDatabase.instance.getCheckInDatesForHabit(
      _habit['id'] as int,
    );

    final suggestion = calculateGardenGuideSuggestion(
      checkInDates: checkInDates,
      startedLocalDate: startedDate as String,
      asOfDate: DateTime.now(),
    );

    if (!mounted) return;

    setState(() {
      _gardenGuideSuggestion = suggestion;
    });
  }
  // method allows user to apply ai helper 
  Future<void> _applyGardenGuideSuggestion() async {
    final suggestion =
        _gardenGuideSuggestion!['suggestedTarget'] as int;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Garden Guide Suggestion?'),
        content: Text(
          'Would you like to update your weekly target to $suggestion?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await HabitDatabase.instance.updateHabit(
      _habit['id'] as int,
      {'weeklyTarget': suggestion},
    );
    if (!mounted) return;
    setState(() {
      _habit = {
        ..._habit,
        'weeklyTarget': suggestion,
      };
      _checkInFuture =
          HabitDatabase.instance.getWeeklyCheckInCounts();
      _gardenGuideChoice = 'applied';
    });
  }
// Garden Guide card
Widget _gardenGuideCard() {
  if (_habit['startedLocalDate'] == null) {
    return const SizedBox.shrink();
  }

  if (_gardenGuideSuggestion == null) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        'Garden Guide: Not enough history yet. Keep checking in!',
        textAlign: TextAlign.center,
      ),
    );
}

    final suggestion =
        _gardenGuideSuggestion!['suggestedTarget'] as int;
    final counts =
        _gardenGuideSuggestion!['weekCounts'] as List<int>;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(175, 231, 211, 163),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Garden Guide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your last three completed weeks: '
            '${counts[0]}, ${counts[1]}, and ${counts[2]} check-ins.',
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your history, your suggested weekly target is $suggestion.',
          ),
          const SizedBox(height: 8),
          const Text(
            'This is a simple history-based suggestion, not a prediction.',
          ),
          const SizedBox(height: 12),
          if (_gardenGuideChoice == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyGardenGuideSuggestion,
                    child: const Text('Apply Suggestion'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _gardenGuideChoice = 'kept';
                      });
                    },
                    child: const Text('Keep My Target'),
                  ),
                ),
              ],
            )
          else
            Text(
              _gardenGuideChoice == 'applied'
                  ? 'Your weekly target has been updated to $suggestion.'
                  : 'Your current weekly target of ${_habit['weeklyTarget']} remains unchanged.',
            ),
                  ],
                ),
              );
            }
  @override
  Widget build(BuildContext context) {
    final habit = _habit;
    final weeklyTarget = habit['weeklyTarget'] as int;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 232, 213),
      appBar: AppBar(
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateHabitScreen(
                      habit: habit,
                    ),
                  ),
                );

                if (!mounted) return;

                if (result == true) {
                  setState(() {
                    _checkInFuture =
                        HabitDatabase.instance.getWeeklyCheckInCounts();

                    _checkInDatesFuture =
                        HabitDatabase.instance.getCheckInDatesForHabit(
                      habit['id'] as int,
                    );
                  });
                }
              },
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
                    // fit image to box instead of hard code
                    Flexible(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          habit['iconPath'] as String,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 3,
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
                // checkin/ start button plus logic 
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
                  //button logic to switch from start to check in
                  child: ElevatedButton(
                    onPressed: () async {
                      if (habit['status'] == 'notStarted') {
                        final startDate =
                            DateTime.now().toIso8601String().split('T')[0];
                        await HabitDatabase.instance.updateHabitStatus(
                          habit['id'] as int,
                          'active',
                          startDate,
                        );
                      } else if (habit['status'] == 'active') {
                        final result = await HabitDatabase.instance.addCheckIn(
                          habit['id'] as int,
                          DateTime.now(),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result == 0
                                  ? 'Already checked in today!'
                                  : 'Check-in saved!',
                            ),
                          ),
                        );
                      }
                      if (!mounted) return;
                      final updatedHabits = await HabitDatabase.instance.getHabits();
                      final currentHabit = updatedHabits.firstWhere(
                        (item) => item['id'] == habit['id'],
                      );
                      setState(() {
                        _habit = currentHabit;
                        _checkInFuture =
                            HabitDatabase.instance.getWeeklyCheckInCounts();
                        _checkInDatesFuture =
                            HabitDatabase.instance.getCheckInDatesForHabit(
                          habit['id'] as int,
                        );
                      });
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
                    child: Text(
                      habit['status'] == 'notStarted'
                          ? 'Start Habit'
                          : habit['status'] == 'finished'
                              ? 'Finished'
                              : 'Check In Today',
                      style: const TextStyle(
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
                        onPressed: () async {
                          await HabitDatabase.instance.updateHabitStatus(
                            habit['id'] as int,
                            'finished',
                            habit['startedLocalDate'] as String?,
                          );

                          if (!mounted) return;
                          Navigator.pop(context, true);
                        },
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
                    // RESET BUTTON
                    const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          // reset logic
                          onPressed: () async {
                            await HabitDatabase.instance.updateHabitStatus(
                              habit['id'] as int,
                              'notStarted',
                              null,
                            );
                            if (!mounted) return;
                            setState(() {
                              _habit = {
                                ...habit,
                                'status': 'notStarted',
                                'startedLocalDate': null,
                              };
                              _checkInFuture =
                                  HabitDatabase.instance.getWeeklyCheckInCounts();
                              _checkInDatesFuture =
                                  HabitDatabase.instance.getCheckInDatesForHabit(
                                habit['id'] as int,
                              );
                            });
                          },
                          // button UI
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
                    // DELETE BUTTON 
                    const SizedBox(width: 8),
                    // adding in logic for delete button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Habit?'),
                              content: const Text(
                                'Are you sure you want to delete this habit? '
                                'Its check-in history will also be deleted.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          //deletion accros cascade
                          if (confirmDelete != true || !mounted) return;
                          await HabitDatabase.instance.deleteHabit(
                            habit['id'] as int,
                          );
                          if (!mounted) return;
                          Navigator.pop(context, true);
                        },
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
                // Garden Guide: ai helper
                const SizedBox(height: 20),
                _gardenGuideCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

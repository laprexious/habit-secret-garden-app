
import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
      ),
      body: const Center(
        child: Text('Your habit details will appear here.'),
      ),
    );
  }
}

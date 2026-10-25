import 'package:flutter/material.dart';

class NewHabitScreen extends StatelessWidget {
  const NewHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
      ),
      body: const Center(
        child: Text('Create your new habit here.'),
      ),
    );
  }
}

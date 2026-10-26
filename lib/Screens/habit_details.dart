
import 'package:flutter/material.dart';

class NewHabitScreen extends StatelessWidget {
  const NewHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text('New Habit'),
      ),
      body: const Center(
        child: Text('Create your new habit here.'),
      ),
    );
  }
}

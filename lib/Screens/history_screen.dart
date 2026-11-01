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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        title: const Text('History & Insights'),
      ),
      body: const Center(
        child: Text('Your habit history will appear here.'),
      ),
    );
  }
}

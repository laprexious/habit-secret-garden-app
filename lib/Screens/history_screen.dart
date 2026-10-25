import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Insights'),
      ),
      body: const Center(
        child: Text('Your habit history will appear here.'),
      ),
    );
  }
}

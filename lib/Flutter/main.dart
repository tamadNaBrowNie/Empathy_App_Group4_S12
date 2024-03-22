import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<String> journalEntries = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(journalEntries: journalEntries),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MealReminderApp());
}

class MealReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Reminder',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

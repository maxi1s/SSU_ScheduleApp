import 'package:flutter/material.dart';
import 'screens/selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSU Schedule',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
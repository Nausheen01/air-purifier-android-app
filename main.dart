// This is the main file of app

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Purify + App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}




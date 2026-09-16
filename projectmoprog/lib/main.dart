import 'package:flutter/material.dart';
import 'package:projectmoprog/screens/splash_screen.dart';

import 'theme/app_theme.dart';
import 'screens/nav_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetContact Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NavScreen(),
    );
  }
}

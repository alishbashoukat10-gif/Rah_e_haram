import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const RahEHaramApp());
}

class RahEHaramApp extends StatelessWidget {
  const RahEHaramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rahe Haram',
      debugShowCheckedModeBanner: false, // Upar wala debug banner hatane ke liye
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(), // App Splash Screen se start hogi
    );
  }
}
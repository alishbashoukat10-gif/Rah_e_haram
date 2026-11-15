import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 3 second baad automatically Welcome screen par jayega
    // (Baad mein yahan token check laga sakte hain: logged in ho to seedha Home)
    _timer = Timer(const Duration(seconds:10 ), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 1. Background Image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // 2. Logo Image (Kaaba with Airplane)
            Image.asset(
              'assets/logo.png',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 30),

            // 3. App Name "Rahe Haram"
            const Text(
              'Rahe Haram',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Serif',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // 4. Divider with Mosque Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 60, height: 1, color: Colors.white70),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.mosque, color: Colors.white, size: 20),
                ),
                Container(width: 60, height: 1, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 15),

            // 5. Tagline
            const Text(
              'your journey,our guidance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.2,
              ),
            ),

            const Spacer(flex: 2),

            // 6. Loading indicator (button ki jagah)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFE5C2)),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
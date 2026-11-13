import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget { // StatefulWidget ki jagah StatelessWidget kar diya hai
  const SplashScreen({super.key});

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
            const Spacer(flex: 2), // Upar se space dene ke liye
            
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
            
            const Spacer(flex: 2), // Text aur button ke darmiyan space
            
            // 6. "Begin your journey" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Ab button dabane par hi Login screen par jayega
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE5C2), // Light peach/beige color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Gol buttons
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Begin your journey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF063D34), // Dark green text
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF063D34),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 50), // Neeche se space
          ],
        ),
      ),
    );
  }
}
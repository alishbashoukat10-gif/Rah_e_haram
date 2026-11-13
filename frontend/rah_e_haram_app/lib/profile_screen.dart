import 'package:flutter/material.dart';
import 'login_screen.dart'; // Logout ke liye

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF063D34); 
    final Color inputBgColor = const Color(0xFFE6F0EB); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- User Info Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: inputBgColor,
                    child: Icon(Icons.person, size: 40, color: primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Faiza Ahmed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('faiza@example.com', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: primaryGreen, size: 20),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Menu Options ---
            _buildMenuOption(Icons.luggage, 'My Trips', () {}),
            _buildMenuOption(Icons.favorite_border, 'Saved Packages', () {}),
            _buildMenuOption(Icons.notifications_none, 'Notifications', () {}),
            _buildMenuOption(Icons.help_outline, 'Help & Support', () {}),
            _buildMenuOption(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
            const SizedBox(height: 24),

            // --- Logout Button ---
            ElevatedButton(
              onPressed: () {
                // Logout karke wapas Login screen par bhej dein
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Menu Options
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF063D34)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
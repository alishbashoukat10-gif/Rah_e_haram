import 'package:flutter/material.dart';
import 'agencies_screen.dart'; 
import 'packages_screen.dart'; // 🔴 Naye imports
import 'my_trips_screen.dart';
import 'guidance_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8), 
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF063D34),
        selectedItemColor: const Color(0xFFF2D6BD), 
        unselectedItemColor: Colors.white70,
        currentIndex: 0, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff), label: 'My Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          // 🔴 Bottom bar ke buttons working
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PackagesScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTripsScreen()));
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Coming Soon!')));
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF063D34), 
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rah-e-Haram', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Your Journey, Our Guidance', style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new notifications')));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Screen')));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 2. Main Body Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Image Banner
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=1000&auto=format&fit=crop'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('Your Journey Begins Here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                  const SizedBox(height: 5),
                  const Text('Plan your Hajj & Umrah with confidence.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search packages...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF063D34)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text('Explore Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                  const SizedBox(height: 15),

                  // Grid of Features
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          title: 'Verified\nOperators',
                          icon: Icons.verified_user,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AgenciesScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          title: 'Packages',
                          icon: Icons.card_travel,
                          onTap: () {
                            // 🔴 Working button
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PackagesScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          title: 'My Trips',
                          icon: Icons.flight_takeoff,
                          onTap: () {
                            // 🔴 Working button
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTripsScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          title: 'Guidance',
                          icon: Icons.menu_book,
                          onTap: () {
                            // 🔴 Working button
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidanceScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Feature Card Widget
  Widget _buildFeatureCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF063D34)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
            ),
          ],
        ),
      ),
    );
  }
}
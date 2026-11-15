import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'agencies_screen.dart';
import 'packages_screen.dart';
import 'my_trips_screen.dart';
import 'profile_screen.dart'; // 🔴 Profile screen ka import

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6), // Cream/Beige theme
      
      // 🔴 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF063D34),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // 🔴 Profile (index 3) par click karne se nayi screen khulegi
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff), label: 'My Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      
      body: _currentIndex == 0
          ? _buildHomeContent(context)
          : _currentIndex == 1
              ? const PackagesScreen()
              : _currentIndex == 2
                  ? const MyTripsScreen()
                  : const Center(child: Text('Profile Screen Coming Soon')),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔴 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Color(0xFF063D34), size: 28),
                const Text(
                  'Rah e Haram',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF063D34), fontFamily: 'Serif'),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none, color: Color(0xFF063D34)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔴 Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search packages...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔴 Namaz Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4B07A), Color(0xFFEBD6B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Salah | Dhuhur',
                        style: TextStyle(fontSize: 12, color: Color(0xFF063D34), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '12:21 PM',
                        style: TextStyle(fontSize: 28, color: Color(0xFF063D34), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF063D34), size: 16),
                          const SizedBox(width: 5),
                          const Text('Masjid Al Haram', style: TextStyle(fontSize: 12, color: Color(0xFF063D34))),
                          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF063D34), size: 16),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=100&auto=format&fit=crop',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🔴 Grid Modules
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 20,
              childAspectRatio: 0.8,
              children: [
                _buildModernModule(
                  context,
                  title: 'Verified\nOperators',
                  icon: Icons.verified_user,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AgenciesScreen()));
                  },
                ),
                _buildModernModule(
                  context,
                  title: 'Packages',
                  icon: Icons.card_travel,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),
                _buildModernModule(
                  context,
                  title: 'My Trips',
                  icon: Icons.flight_takeoff,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                  },
                ),
                _buildModernModule(
                  context,
                  title: 'Guidance',
                  icon: Icons.menu_book,
                  onTap: () {},
                ),
                _buildModernModule(
                  context,
                  title: 'Qibla\nFinder',
                  icon: Icons.explore,
                  onTap: () {},
                ),
                _buildModernModule(
                  context,
                  title: 'Prayer\nTime',
                  icon: Icons.access_time,
                  onTap: () {},
                ),
                _buildModernModule(
                  context,
                  title: 'Duas',
                  icon: Icons.favorite,
                  onTap: () {},
                ),
                _buildModernModule(
                  context,
                  title: 'Tawaf\nCounter',
                  icon: Icons.repeat,
                  onTap: () {},
                ),
                _buildModernModule(
                  context,
                  title: 'Travel\nGuide',
                  icon: Icons.map,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔴 Featured Packages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Featured Package', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                TextButton(
                  onPressed: () {
                    setState(() => _currentIndex = 1);
                  },
                  child: const Text('View All →', style: TextStyle(color: Color(0xFFD4AF37))),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dummy Package Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=200&auto=format&fit=crop',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Umrah Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                          const SizedBox(height: 5),
                          const Text('15 Days · 5 Star Hotel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() => _currentIndex = 1);
                            },
                            child: const Text('View Details →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔴 Custom Module Widget
  Widget _buildModernModule(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.transparent, 
            ),
            child: Icon(icon, size: 35, color: const Color(0xFF063D34)),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
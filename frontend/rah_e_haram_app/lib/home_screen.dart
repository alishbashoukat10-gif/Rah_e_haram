
import 'package:flutter/material.dart';
import 'agencies_screen.dart';
import 'packages_screen.dart';
import 'my_trips_screen.dart';
import 'guidance_screen.dart';
import 'requirements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFB58A3A);

  String selectedJourney = 'Umrah';
  String? selectedQuickSearch;
  int selectedNavIndex = 0;

  void openScreen(Widget screen, int index) {
    setState(() {
      selectedNavIndex = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) {
      if (mounted) {
        setState(() {
          selectedNavIndex = 0;
        });
      }
    });
  }

  // Hajj and Umrah journey cards
  Widget journeyCard({
    required String title,
    required String subtitle,
    required String image,
  }) {
    final bool isSelected = selectedJourney == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedJourney = title;
            selectedQuickSearch = null;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequirementsScreen(
                packageType: title,
              ),
            ),
          );
        },
        child: Container(
          height: 145,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? gold : Colors.transparent,
              width: 3,
            ),
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.42),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Positioned(
                  right: 9,
                  top: 9,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick search chips
  Widget quickSearch(String title) {
    final bool isSelected = selectedQuickSearch == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuickSearch = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? green : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : green,
          ),
        ),
      ),
    );
  }

  // Dashboard feature cards
  Widget featureCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green, size: 27),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: green,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                decoration: const BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahe Haram',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Assalamu Alaikum!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Your journey, guided with trust.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No new notifications'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search packages or operators...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: green,
                        ),
                        suffixIcon: const Icon(
                          Icons.tune,
                          color: green,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 23),

                    // Journey selection
                    const Text(
                      'Choose Your Journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D34),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        journeyCard(
                          title: 'Hajj',
                          subtitle: 'Explore Hajj packages',
                          image:
                              'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?w=800',
                        ),
                        const SizedBox(width: 12),
                        journeyCard(
                          title: 'Umrah',
                          subtitle: 'Explore Umrah packages',
                          image:
                              'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=800',
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Quick searches
                    const Text(
                      'Quick Searches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D34),
                      ),
                    ),

                    const SizedBox(height: 11),

                    Wrap(
                      spacing: 8,
                      runSpacing: 9,
                      children: [
                        quickSearch('7 days · Under 100k'),
                        quickSearch('10 days · Under 120k'),
                        quickSearch('14 days · Under 150k'),
                        quickSearch('21 days · Under 200k'),
                        quickSearch('Budget Friendly'),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Booking status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Bookings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF063D34),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            openScreen(const MyTripsScreen(), 1);
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(color: green),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.luggage_outlined,
                            color: gold,
                            size: 34,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No active bookings',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Your booking requests and confirmations will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 23),

                    // Explore services
                    const Text(
                      'Explore Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D34),
                      ),
                    ),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        Expanded(
                          child: featureCard(
                            'Verified Operators',
                            Icons.verified_user_outlined,
                            () => openScreen(
                              const AgenciesScreen(),
                              0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: featureCard(
                            'Packages',
                            Icons.card_travel,
                            () => openScreen(
                              const PackagesScreen(),
                              0,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: featureCard(
                            'Guidance',
                            Icons.menu_book_outlined,
                            () => openScreen(
                              const GuidanceScreen(),
                              2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: featureCard(
                            'Complaints',
                            Icons.report_problem_outlined,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Complaints section will be connected next.',
                                  ),
                                ),
                              );
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
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: green,
        selectedItemColor: const Color(0xFFF2D6BD),
        unselectedItemColor: Colors.white70,
        currentIndex: selectedNavIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              selectedNavIndex = 0;
            });
          } else if (index == 1) {
            openScreen(const MyTripsScreen(), 1);
          } else if (index == 2) {
            openScreen(const GuidanceScreen(), 2);
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile screen will be connected.'),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'AI Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

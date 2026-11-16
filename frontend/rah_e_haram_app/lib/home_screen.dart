
import 'package:flutter/material.dart';

import 'agencies_screen.dart';
import 'packages_screen.dart';
import 'my_trips_screen.dart';
import 'guidance_screen.dart';
import 'requirements_screen.dart';
import 'customization_screen.dart';
import 'my_customization_requests_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = '',
  });

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

  void openPackages() {
    openScreen(const PackagesScreen(), 0);
  }

  void openRequirements() {
    openScreen(
      RequirementsScreen(packageType: selectedJourney),
      0,
    );
  }

  void openCustomization() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please select a package first to customize your journey.',
        ),
      ),
    );
    openPackages();
  }

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

  Widget quickSearch(String title) {
    final bool isSelected = selectedQuickSearch == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuickSearch = title;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title selected. Open Packages to explore available options.',
            ),
          ),
        );
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

  Widget featureCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 105,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String greetingName = widget.userName.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard header
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rahe Haram',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          greetingName.isEmpty
                              ? 'Assalamu Alaikum!'
                              : 'Assalamu Alaikum, $greetingName!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
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
                    // Search
                    TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => openPackages(),
                      decoration: InputDecoration(
                        hintText: 'Search packages or operators...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: green,
                        ),
                        suffixIcon: IconButton(
                          onPressed: openPackages,
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: green,
                          ),
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

                    sectionTitle('Choose Your Journey'),

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

                    sectionTitle('Quick Searches'),

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

                    // My Bookings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        sectionTitle('My Bookings'),
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

                    InkWell(
                      onTap: () {
                        openScreen(const MyTripsScreen(), 1);
                      },
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.luggage_outlined,
                              color: gold,
                              size: 34,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your bookings',
                              style: TextStyle(
                                color: green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'View your booking requests and confirmations.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 23),

                    // Explore Services
                    sectionTitle('Explore Services'),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        featureCard(
                          'Verified Operators',
                          Icons.verified_user_outlined,
                          () => openScreen(
                            const AgenciesScreen(),
                            0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        featureCard(
                          'Packages',
                          Icons.card_travel,
                          openPackages,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        featureCard(
                          'Guidance',
                          Icons.menu_book_outlined,
                          () => openScreen(
                            const GuidanceScreen(),
                            2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        featureCard(
                          'My Trips',
                          Icons.flight_takeoff,
                          () => openScreen(
                            const MyTripsScreen(),
                            1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        featureCard(
                          'Customize Trip',
                          Icons.tune,
                          openCustomization,
                        ),
                        const SizedBox(width: 12),
                        featureCard(
                          'My Customization Requests',
                          Icons.edit_calendar_outlined,
                          () => openScreen(
                            const MyCustomizationRequestsScreen(),
                            0,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        featureCard(
                          'Find My Package',
                          Icons.recommend_outlined,
                          openRequirements,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: SizedBox(height: 105),
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
            openScreen(const ProfileScreen(), 3);
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
            icon: Icon(Icons.menu_book_outlined),
            label: 'Guidance',
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

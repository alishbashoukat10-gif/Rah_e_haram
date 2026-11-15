import 'package:flutter/material.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> packages = [
      {
        'title': 'Umrah Economy Package',
        'duration': '14 Days',
        'price': 'Rs. 150,000',
        'hotel': '3-Star Hotel',
        'image': 'https://crm.dtravel.pk/cdn-cgi/image/width=3840,quality=55,format=auto/storage/uploads/blog/2026/08/1785906674-77489153-182f-4b9c-bda3-eec74b0d168a.webp',
      },
      {
        'title': 'Umrah Premium Package',
        'duration': '21 Days',
        'price': 'Rs. 250,000',
        'hotel': '5-Star Hotel',
        'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQkwilRCrvjo6oRjADDGoTE1OxyE29f7eXf3YXM5bJ9pZbZScfU-2eSJHQ&s=10',
      },
      {
        'title': 'Hajj Economy Package',
        'duration': '30 Days',
        'price': 'Rs. 450,000',
        'hotel': '3-Star Hotel',
        'image': 'https://al-khair.org/wp-content/uploads/2024/09/Ramadan-Umrah-Packages-2016-1024x356-1.jpg',
      },
      {
        'title': 'Hajj Premium Package',
        'duration': '40 Days',
        'price': 'Rs. 650,000',
        'hotel': '5-Star Hotel',
        'image': 'https://travelix.pk/images/madinah_showcase.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text('Packages', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔴 Image (Har package ki alag)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    pkg['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(pkg['duration'], style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 15),
                          const Icon(Icons.hotel, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(pkg['hotel'], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pkg['price'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking feature coming soon!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF063D34),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
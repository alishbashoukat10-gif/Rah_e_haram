
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  late Future<List<dynamic>> packagesFuture;

  @override
  void initState() {
    super.initState();
    packagesFuture = ApiService.fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text(
          'Packages',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: packagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF063D34),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load packages',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          packagesFuture = ApiService.fetchPackages();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final packages = snapshot.data ?? [];

          if (packages.isEmpty) {
            return const Center(
              child: Text(
                'No packages available yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final agency = package['agency'] is Map
                  ? package['agency']
                  : {};

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package['packageName'] ?? 'Unnamed Package',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF063D34),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${package['packageType'] ?? 'N/A'}',
                      ),
                      Text(
                        'Agency: ${agency['name'] ?? 'N/A'}',
                      ),
                      Text(
                        'City: ${agency['city'] ?? 'N/A'}',
                      ),
                      Text(
                        'Duration: ${package['durationDays'] ?? 0} days',
                      ),
                      Text(
                        'Hotel Quality: ${package['hotelQuality'] ?? 'N/A'}/5',
                      ),
                      Text(
                        'Transport Quality: ${package['transportQuality'] ?? 'N/A'}/5',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rs. ${package['price'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB58A3A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

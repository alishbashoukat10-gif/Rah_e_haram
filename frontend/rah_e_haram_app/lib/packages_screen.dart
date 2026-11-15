
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFD4AF37);

  late Future<List<dynamic>> packagesFuture;

  @override
  void initState() {
    super.initState();
    packagesFuture = ApiService.fetchPackages();
  }

  void loadPackages() {
    setState(() {
      packagesFuture = ApiService.fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: green,
        title: const Text(
          'Packages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: packagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load packages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadPackages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final packages = snapshot.data ?? [];

          if (packages.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => loadPackages(),
              color: green,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No packages available yet.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => loadPackages(),
            color: green,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];

                final agency = package['agency'] is Map
                    ? package['agency'] as Map
                    : {};

                final packageName =
                    package['packageName']?.toString() ??
                    'Unnamed Package';

                final packageType =
                    package['packageType']?.toString() ?? 'N/A';

                final agencyName =
                    agency['name']?.toString() ?? 'N/A';

                final agencyCity =
                    agency['city']?.toString() ?? 'N/A';

                final duration =
                    package['durationDays']?.toString() ?? '0';

                final hotelQuality =
                    package['hotelQuality']?.toString() ?? 'N/A';

                final transportQuality =
                    package['transportQuality']?.toString() ?? 'N/A';

                final price = package['price'] ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: green.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.mosque_outlined,
                                color: green,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                packageName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: green,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Package Type: $packageType',
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          'Agency: $agencyName',
                          style: const TextStyle(fontSize: 14),
                        ),

                        Text(
                          'City: $agencyCity',
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text('$duration Days'),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            const Icon(
                              Icons.hotel_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Hotel Quality: $hotelQuality/5',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Transport Quality: $transportQuality/5',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        const Divider(),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Package Price',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Rs. $price',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

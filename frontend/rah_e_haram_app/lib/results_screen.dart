
import 'package:flutter/material.dart';
import 'package_details_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<dynamic> results;
  final String packageType;

  const ResultsScreen({
    super.key,
    required this.results,
    required this.packageType,
  });

  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFB58A3A);

  // FORMAT PACKAGE PRICE
  String formatPrice(dynamic price) {
    final amount = double.tryParse(price?.toString() ?? '');

    if (amount == null || !amount.isFinite) {
      return 'Price unavailable';
    }

    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  // READ TOPSIS SCORE FROM BACKEND
  double getScore(Map<String, dynamic> package) {
    final rawScore = package['topsisScore'] ?? package['score'];

    final score = double.tryParse(rawScore?.toString() ?? '');

    if (score == null || !score.isFinite) {
      return 0;
    }

    return score.clamp(0.0, 1.0).toDouble();
  }

  // DISPLAY PACKAGE INFORMATION
  Widget infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: green),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // DISPLAY EACH PACKAGE
  Widget packageCard(
    BuildContext context,
    Map<String, dynamic> package,
    int index,
  ) {
    final agency = package['agency'];

    final agencyName = agency is Map
        ? agency['name']?.toString() ?? 'Agency'
        : 'Agency';

    final city = agency is Map
        ? agency['city']?.toString() ?? ''
        : '';

    final score = getScore(package);

    final rank = package['rank'] ?? index + 1;

    final isBestMatch = package['isBestMatch'] == true;

    final packageName =
        package['packageName']?.toString() ?? 'Unnamed Package';

    final duration = package['durationDays']?.toString() ?? '-';

    final hotelQuality = package['hotelQuality']?.toString() ?? '-';

    final transportQuality =
        package['transportQuality']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isBestMatch ? gold : const Color(0xFFEAEAEA),
          width: isBestMatch ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RANK AND BEST MATCH
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rank #$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                if (isBestMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BEST MATCH',
                      style: TextStyle(
                        color: Color(0xFF8B641F),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 13),

            // PACKAGE NAME
            Text(
              packageName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 5),

            // AGENCY INFORMATION
            Text(
              agencyName + (city.isNotEmpty ? ' · $city' : ''),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 14),

            // PACKAGE FEATURES
            Wrap(
              spacing: 15,
              runSpacing: 8,
              children: [
                infoItem(
                  Icons.calendar_month_outlined,
                  '$duration days',
                ),
                infoItem(
                  Icons.hotel_outlined,
                  'Hotel $hotelQuality/5',
                ),
                infoItem(
                  Icons.directions_bus_outlined,
                  'Transport $transportQuality/5',
                ),
              ],
            ),

            const Divider(height: 25),

            // PRICE AND TOPSIS SCORE
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Package Price',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatPrice(package['price']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOPSIS Score',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${(score * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 13),

            // PACKAGE DETAILS BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PackageDetailsScreen(
                        package: package,
                      ),
                    ),
                  );
                },
                child: const Text('View Package Details'),
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
      backgroundColor: const Color(0xFFF8F8F5),
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recommended Packages',
          style: TextStyle(fontSize: 18),
        ),
      ),

      body: results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 55,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'No Packages Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No packages match your selected budget and journey type. '
                      'Try increasing your budget or changing your requirements.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Change Requirements'),
                    ),
                  ],
                ),
              ),
            )

          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$packageType Packages',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${results.length} packages ranked according to your priorities',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final package = Map<String, dynamic>.from(
                        results[index] as Map,
                      );

                      return packageCard(
                        context,
                        package,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}


import 'package:flutter/material.dart';
import 'customization_screen.dart';
import 'services/api_service.dart';

class PackageDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> package;

  const PackageDetailsScreen({
    super.key,
    required this.package,
  });

  @override
  State<PackageDetailsScreen> createState() =>
      _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFB58A3A);

  bool isBooking = false;

  Widget detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: green, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmBooking() async {
    final packageId = widget.package['_id']?.toString();

    if (packageId == null || packageId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package ID is missing.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
          'Do you want to book this package?\n\n'
          'Package: ${widget.package['packageName'] ?? 'Package'}\n'
          'Price: Rs. ${widget.package['price'] ?? 0}\n\n'
          'Your booking will initially have Pending status. '
          'The agency must confirm availability and final details.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      isBooking = true;
    });

    try {
      final result = await ApiService.createStandardBooking(
        packageId: packageId,
      );

      if (!mounted) return;

      setState(() {
        isBooking = false;
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: green,
            size: 48,
          ),
          title: const Text('Booking Submitted!'),
          content: Text(
            '${result['message'] ?? 'Your booking has been submitted.'}\n\n'
            'Status: ${result['booking']?['status'] ?? 'Pending'}\n'
            'Amount: Rs. ${result['booking']?['totalAmount'] ?? widget.package['price']}',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isBooking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final agency = package['agency'];

    final agencyName = agency is Map
        ? agency['name']?.toString() ?? 'Agency'
        : 'Agency';

    final city = agency is Map
        ? agency['city']?.toString() ?? 'Not provided'
        : 'Not provided';

    final price = package['price'] ?? 0;
    final duration = package['durationDays'] ?? '-';
    final hotel = package['hotelQuality'] ?? '-';
    final transport = package['transportQuality'] ?? '-';

    final description =
        package['description']?.toString() ??
            'No description available.';

    final score =
        (package['topsisScore'] as num?)?.toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text('Package Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RAHE HARAM',
                    style: TextStyle(
                      color: Color(0xFFD8BB7B),
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    package['packageName']?.toString() ??
                        'Package Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package['packageType']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rs. ${price.toString()}',
                    style: const TextStyle(
                      color: Color(0xFFD8BB7B),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Package price',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Package Information',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                ),
              ),
              child: Column(
                children: [
                  detailRow(
                    Icons.business_outlined,
                    'Travel Agency',
                    agencyName,
                  ),
                  const Divider(height: 1),
                  detailRow(
                    Icons.location_on_outlined,
                    'Agency City',
                    city,
                  ),
                  const Divider(height: 1),
                  detailRow(
                    Icons.calendar_month_outlined,
                    'Duration',
                    '$duration days',
                  ),
                  const Divider(height: 1),
                  detailRow(
                    Icons.hotel_outlined,
                    'Hotel Quality',
                    '$hotel / 5',
                  ),
                  const Divider(height: 1),
                  detailRow(
                    Icons.directions_bus_outlined,
                    'Transport Quality',
                    '$transport / 5',
                  ),
                  if (package['rank'] != null) ...[
                    const Divider(height: 1),
                    detailRow(
                      Icons.leaderboard_outlined,
                      'TOPSIS Rank',
                      '#${package['rank']}',
                    ),
                  ],
                  if (score != null) ...[
                    const Divider(height: 1),
                    detailRow(
                      Icons.analytics_outlined,
                      'TOPSIS Score',
                      '${(score * 100).toStringAsFixed(2)}%',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Package Description',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 9),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                ),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5DF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: gold,
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Package prices and availability should be confirmed '
                      'with the travel agency before booking or payment.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Standard booking button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isBooking ? null : confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Book This Package',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Customization button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomizationScreen(
                        package: package,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Customize This Package',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

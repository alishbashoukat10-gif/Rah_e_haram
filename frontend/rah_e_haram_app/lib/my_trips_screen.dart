
import 'package:flutter/material.dart';
import 'my_customization_requests_screen.dart';
import 'services/api_service.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFC6A15B);

  late Future<List<dynamic>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = ApiService.getMyBookings();
  }

  Future<void> refreshBookings() async {
    final future = ApiService.getMyBookings();

    setState(() {
      bookingsFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder handles and displays the error.
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return 'Date unavailable';

    try {
      final parsedDate = DateTime.parse(date.toString()).toLocal();
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (_) {
      return 'Date unavailable';
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return gold;
    }
  }

  Widget bookingCard(Map<String, dynamic> booking) {
    final package = booking['package'] is Map
        ? Map<String, dynamic>.from(booking['package'])
        : <String, dynamic>{};

    final agency = package['agency'] is Map
        ? Map<String, dynamic>.from(package['agency'])
        : <String, dynamic>{};

    final packageName =
        package['packageName']?.toString() ?? 'Package';

    final packageType =
        package['packageType']?.toString() ?? 'Journey';

    final agencyName =
        agency['name']?.toString() ?? 'Travel Agency';

    final amount = booking['totalAmount'] ?? 0;

    final status =
        booking['status']?.toString() ?? 'Pending';

    final bookingType =
        booking['bookingType']?.toString() ?? 'Standard';

    final bookingDate = formatDate(booking['createdAt']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.luggage_outlined,
                color: gold,
                size: 25,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  packageName,
                  style: const TextStyle(
                    color: green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          detailRow(Icons.mosque_outlined, 'Journey', packageType),
          detailRow(Icons.business_outlined, 'Agency', agencyName),
          detailRow(Icons.category_outlined, 'Booking Type', bookingType),
          detailRow(
            Icons.calendar_today_outlined,
            'Booking Date',
            bookingDate,
          ),
          detailRow(
            Icons.payments_outlined,
            'Amount',
            'Rs. ${amount.toString()}',
          ),

          const SizedBox(height: 10),
          const Divider(),

          Text(
            status.toLowerCase() == 'pending'
                ? 'Your booking is waiting for agency confirmation.'
                : status.toLowerCase() == 'confirmed'
                    ? 'Your booking has been confirmed.'
                    : status.toLowerCase() == 'cancelled'
                        ? 'This booking has been cancelled.'
                        : 'Your booking status is being updated.',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bookingsSection() {
    return FutureBuilder<List<dynamic>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(35),
            child: Center(
              child: CircularProgressIndicator(color: green),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 35,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Unable to load bookings.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: refreshBookings,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.luggage_outlined,
                  color: gold,
                  size: 38,
                ),
                SizedBox(height: 12),
                Text(
                  'No Bookings Yet',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your Hajj and Umrah bookings will appear here '
                  'after you book a package.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: bookings.map((item) {
            return bookingCard(
              Map<String, dynamic>.from(item as Map),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: green,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: refreshBookings,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh bookings',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: green,
        onRefresh: refreshBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Manage Your Bookings',
              style: TextStyle(
                color: green,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'View your Hajj and Umrah bookings and track their status.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'My Bookings',
              style: TextStyle(
                color: green,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 13),

            bookingsSection(),

            const SizedBox(height: 20),

            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MyCustomizationRequestsScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      color: gold,
                      size: 27,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Customization Requests',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Track your package modification requests.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: green,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reviews_screen.dart';
import 'packages_screen.dart'; 

class AgencyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> agency;
  const AgencyDetailsScreen({super.key, required this.agency});

  // 🔴 Call Function (Fixed)
  Future<void> _makeCall(String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch $launchUri');
      }
    } catch (e) {
      print(e);
    }
  }

  // 🔴 WhatsApp Function (Fixed)
  Future<void> _openWhatsApp(String number) async {
    String cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '92${cleanNumber.substring(1)}';
    }
    final Uri launchUri = Uri.parse("https://wa.me/$cleanNumber");
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $launchUri');
      }
    } catch (e) {
      print(e);
    }
  }

  // 🔴 Email Function (Fixed)
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email.trim());
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch $launchUri');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> services = agency['services'] ?? [];
    String email = agency['email'] ?? 'No email provided';
    String whatsapp = agency['whatsapp'] ?? agency['contactNumber'] ?? '';
    String phone = agency['contactNumber'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: Text(agency['name'] ?? 'Agency Details', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔴 Header Section with Unique Logo
            Center(
              child: Column(
                children: [
                  // 🔴 Logo (Agency ke naam ka pehla letter)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE6F0EB),
                    child: Text(
                      agency['name'] != null && agency['name'].isNotEmpty
                          ? agency['name'][0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D34),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        agency['name'] ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                      ),
                      const SizedBox(width: 8),
                      if (agency['isVerified'] == true)
                        const Icon(Icons.verified, color: Colors.blue, size: 28),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'License: ${agency['licenseNumber'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 1),

            // 🔴 Rating & City
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 24),
                        const SizedBox(width: 5),
                        Text('${agency['rating'] ?? 0.0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Text('Rating', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF063D34), size: 24),
                        const SizedBox(width: 5),
                        Text(agency['city'] ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Text('Location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔴 Services Section
            const Text('Services Provided', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
            const SizedBox(height: 10),
            services.isEmpty
                ? const Text('No services listed for this agency.', style: TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: services.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0EB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF063D34).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFF063D34)),
                            const SizedBox(width: 5),
                            Text(service.toString(), style: const TextStyle(color: Color(0xFF063D34), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 30),

            // 🔴 Contact Information
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
            const SizedBox(height: 15),
            _buildInfoTile(Icons.email, 'Email', email),
            const SizedBox(height: 10),
            _buildInfoTile(Icons.phone, 'Phone', phone),
            const SizedBox(height: 30),

            // 🔴 Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(phone),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text('Call Now', style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF063D34),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(whatsapp),
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Email Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _sendEmail(email),
                icon: const Icon(Icons.email, color: Color(0xFF063D34)),
                label: const Text('Send Email', style: TextStyle(color: Color(0xFF063D34), fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Color(0xFF063D34)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // 🔴 View Packages Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PackagesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Packages', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),

            // 🔴 Reviews Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsScreen(agency: agency),
                    ),
                  );
                },
                icon: const Icon(Icons.star, color: Color(0xFFD4AF37)),
                label: const Text('Read Reviews & Ratings', style: TextStyle(color: Color(0xFF063D34), fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF063D34), size: 20),
        const SizedBox(width: 10),
        Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))),
      ],
    );
  }
}
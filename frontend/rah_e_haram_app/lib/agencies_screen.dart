import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'agency_details_screen.dart'; // Details screen ka import

class AgenciesScreen extends StatefulWidget {
  const AgenciesScreen({super.key});

  @override
  State<AgenciesScreen> createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends State<AgenciesScreen> {
  List<dynamic> agencies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAgencies();
  }

  Future<void> fetchAgencies() async {
    // Apna IP address yahan check kar lein
    var url = Uri.parse('http://192.168.18.13:5000/api/agencies');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          agencies = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text('Verified Operators', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agencies.isEmpty
              ? const Center(child: Text('No agencies found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: agencies.length,
                  itemBuilder: (context, index) {
                    final agency = agencies[index];
                    
                    // 🔴 Yahan humne Card ko InkWell ke andar rakha hai taake click ho sake
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Click karne par Details screen par jayega
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgencyDetailsScreen(agency: agency),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    agency['name'],
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                                  ),
                                  if (agency['isVerified'])
                                    const Icon(Icons.verified, color: Colors.blue, size: 24),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(agency['city']),
                                  const SizedBox(width: 15),
                                  const Icon(Icons.star, size: 16, color: Colors.orange),
                                  const SizedBox(width: 5),
                                  Text(agency['rating'].toString()),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('License: ${agency['licenseNumber']}', style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.phone, size: 16),
                                    label: Text(agency['contactNumber']),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
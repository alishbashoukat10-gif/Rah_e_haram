import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'agency_details_screen.dart';

class AgenciesScreen extends StatefulWidget {
  const AgenciesScreen({super.key});

  @override
  State<AgenciesScreen> createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends State<AgenciesScreen> {
  List<dynamic> allAgencies = [];
  List<dynamic> filteredAgencies = [];
  bool isLoading = true;
  String searchQuery = "";
  String selectedFilter = "All"; // All, Top Rated

  @override
  void initState() {
    super.initState();
    fetchAgencies();
  }

  Future<void> fetchAgencies() async {
    var url = Uri.parse('http://192.168.18.13:5000/api/agencies');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> rawData = jsonDecode(response.body);
        
        // 🔴 Duplicate agencies ko hata dein (naam ke hisaab se)
        List<dynamic> uniqueAgencies = [];
        Set<String> seenNames = {};
        for (var agency in rawData) {
          if (!seenNames.contains(agency['name'])) {
            seenNames.add(agency['name']);
            uniqueAgencies.add(agency);
          }
        }

        setState(() {
          allAgencies = uniqueAgencies;
          filteredAgencies = uniqueAgencies;
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

  void _filterAgencies() {
    setState(() {
      filteredAgencies = allAgencies.where((agency) {
        final matchesSearch = agency['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        return matchesSearch;
      }).toList();

      // 🔴 Top Rated ke liye rating ke hisaab se sort karein
      if (selectedFilter == "Top Rated") {
        filteredAgencies.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
      } else {
        // All ke liye naam ke hisaab se sort karein
        filteredAgencies.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text('Verified Operators', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔴 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  searchQuery = value;
                  _filterAgencies();
                },
                decoration: const InputDecoration(
                  hintText: 'Search agency by name...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 🔴 Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip("All"),
                const SizedBox(width: 10),
                _buildFilterChip("Top Rated"),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 🔴 Agencies List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAgencies.isEmpty
                    ? const Center(child: Text('No agencies found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAgencies.length,
                        itemBuilder: (context, index) {
                          final agency = filteredAgencies[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgencyDetailsScreen(agency: agency),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔴 Unique Logo (Naam ka pehla letter)
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: const Color(0xFFE6F0EB),
                                      child: Text(
                                        agency['name'] != null && agency['name'].isNotEmpty
                                            ? agency['name'][0].toUpperCase()
                                            : 'A',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF063D34),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  agency['name'],
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (agency['isVerified'] == true)
                                                const Icon(Icons.verified, color: Colors.blue, size: 20),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                              const SizedBox(width: 5),
                                              Text(agency['city'] ?? 'N/A', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                              const SizedBox(width: 10),
                                              const Icon(Icons.star, size: 14, color: Colors.orange),
                                              const SizedBox(width: 5),
                                              Text('${agency['rating'] ?? 0.0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text('License: ${agency['licenseNumber']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: const [
                                              Text('View Details →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 🔴 Filter Chip Widget
  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          _filterAgencies();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF063D34) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF063D34) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
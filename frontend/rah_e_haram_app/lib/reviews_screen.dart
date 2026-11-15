import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'write_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> agency;
  const ReviewsScreen({super.key, required this.agency});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<dynamic> reviews = [];
  bool isLoading = true;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    var url = Uri.parse('http://192.168.18.13:5000/api/reviews/${widget.agency['_id']}');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          reviews = jsonDecode(response.body);
          isLoading = false;
          if (reviews.isNotEmpty) {
            double total = 0;
            for (var r in reviews) {
              total += r['rating'];
            }
            averageRating = total / reviews.length;
          }
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text('Reviews & Ratings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔴 Overall Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating.round() ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 24,
                            );
                          }),
                        ),
                        const SizedBox(height: 5),
                        Text('Based on ${reviews.length} reviews', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔴 Write a Review Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Write Review screen par jayein
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WriteReviewScreen(agency: widget.agency),
                          ),
                        );
                        // Wapas aane par reviews refresh karein
                        fetchReviews();
                      },
                      icon: const Icon(Icons.rate_review, color: Colors.white),
                      label: const Text('Write a Review', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063D34),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔴 Reviews List
                  const Text('Customer Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
                  const SizedBox(height: 10),
                  
                  reviews.isEmpty
                      ? const Center(child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: const Color(0xFFE6F0EB),
                                          child: const Icon(Icons.person, size: 18, color: Color(0xFF063D34)),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          review['userName'] ?? 'Anonymous',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review['rating'] ? Icons.star : Icons.star_border,
                                          color: Colors.orange,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review['reviewTitle'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF063D34)),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      review['reviewText'] ?? '',
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WriteReviewScreen extends StatefulWidget {
  final Map<String, dynamic> agency;
  const WriteReviewScreen({super.key, required this.agency});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 5.0;
  bool isLoading = false;

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    var url = Uri.parse('http://192.168.18.13:5000/api/reviews/add');
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "agencyId": widget.agency['_id'],
          "agencyName": widget.agency['name'],
          "userName": "Faiza Khan", // Filhal hardcoded, baad mein logged-in user ka naam aayega
          "rating": _rating,
          "reviewTitle": _titleController.text.trim(),
          "reviewText": _reviewController.text.trim(),
        }),
      );

      var data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Wapas Reviews screen par
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text('Write a Review', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reviewing: ${widget.agency['name']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
              ),
              const SizedBox(height: 20),

              // 🔴 Star Rating Selector
              const Text('Rate Your Experience', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF063D34))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // 🔴 Review Title
              const Text('Review Title', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF063D34))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Excellent service!',
                  filled: true,
                  fillColor: const Color(0xFFE6F0EB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),

              // 🔴 Review Text
              const Text('Your Review', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF063D34))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this agency...',
                  filled: true,
                  fillColor: const Color(0xFFE6F0EB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? 'Please write your review' : null,
              ),
              const SizedBox(height: 30),

              // 🔴 Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF063D34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Review', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
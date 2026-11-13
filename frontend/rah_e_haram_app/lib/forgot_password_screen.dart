import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final Color primaryGreen = const Color(0xFF063D34); 
  final Color inputBgColor = const Color(0xFFE6F0EB); 
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 🔴 Apna IP address yahan check kar lein
    var url = Uri.parse('http://192.168.18.13:5000/api/auth/forgot-password');
    
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
        }),
      );

      // Server se aya hua data check karein
      var data = jsonDecode(response.body);

      if (!mounted) return;
      
      if (response.statusCode == 200) {
        // Success Message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Reset link sent!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      } else {
        // Error Message (jaise user nahi mila)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Something went wrong'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Agar network fail ho jaye ya server band ho
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Error: Server is not responding'), backgroundColor: Colors.red),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 50, color: Color(0xFF063D34)),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email address to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF063D34))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your registered email',
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF063D34)),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF063D34)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
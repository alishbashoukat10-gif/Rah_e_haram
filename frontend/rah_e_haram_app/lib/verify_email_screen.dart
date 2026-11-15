
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF063D34); 
    final Color inputBgColor = const Color(0xFFE6F0EB); 
    final Color accentGold = const Color(0xFFD4B07A); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: inputBgColor,
                child: Icon(Icons.mark_email_read_outlined, size: 40, color: primaryGreen),
              ),
              const SizedBox(height: 20),
              Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              const SizedBox(height: 10),
              const Text(
                'We have sent a verification code to your email address. Please enter the code below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter Verification Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF063D34))),
              ),
              const SizedBox(height: 20),

              // 4 Digit OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOtpBox(inputBgColor),
                  _buildOtpBox(inputBgColor),
                  _buildOtpBox(inputBgColor),
                  _buildOtpBox(inputBgColor),
                ],
              ),
              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Verify logic yahan aayega
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification logic coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Verify', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  GestureDetector(
                    onTap: () {
                      // TODO: Resend logic yahan aayega
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code resent successfully!')),
                      );
                    },
                    child: Text('Resend Code', style: TextStyle(color: accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for OTP box
  Widget _buildOtpBox(Color bgColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            hintText: "-",
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063D34),
        title: const Text('Guidance', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text('Hajj & Umrah guidance and Duas will appear here.', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
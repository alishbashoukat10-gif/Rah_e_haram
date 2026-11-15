
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static String? authToken;

  static void setToken(String token) {
    authToken = token;
  }

  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (authToken != null)
          'Authorization': 'Bearer $authToken',
      };

  // 1. Fetch all active packages
  static Future<List<dynamic>> fetchPackages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/packages'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load packages: ${response.body}');
  }

  // 2. Get TOPSIS package recommendations
  static Future<dynamic> recommendPackages({
    required double maxBudget,
    required int durationDays,
    required Map<String, double> weights,
    required String packageType,
  }) async {
    if (!['Hajj', 'Umrah'].contains(packageType)) {
      throw Exception('Package type must be Hajj or Umrah.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/packages/recommend'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'maxBudget': maxBudget,
        'durationDays': durationDays,
        'weights': weights,
        'packageType': packageType,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Recommendation failed',
    );
  }

  // 3. Submit package customization request
  static Future<Map<String, dynamic>> submitCustomization({
    required String packageId,
    required int requestedDuration,
    required String specialRequirements,
  }) async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first to submit a request.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/customizations'),
      headers: authHeaders,
      body: jsonEncode({
        'packageId': packageId,
        'requestedDuration': requestedDuration,
        'specialRequirements': specialRequirements,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to submit customization request',
    );
  }

  // 4. Get logged-in pilgrim's customization requests
  static Future<List<dynamic>> getMyCustomizationRequests() async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/customizations/my-requests'),
      headers: authHeaders,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['requests'] as List<dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to retrieve customization requests',
    );
  }

  // 5. Accept an agency customization offer
  static Future<Map<String, dynamic>> acceptCustomizationOffer({
    required String requestId,
    required String responseId,
  }) async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/customizations/$requestId/accept'),
      headers: authHeaders,
      body: jsonEncode({
        'responseId': responseId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to accept agency offer',
    );
  }

  // 6. Reject an agency customization offer
  static Future<Map<String, dynamic>> rejectCustomizationOffer({
    required String requestId,
    required String responseId,
  }) async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/customizations/$requestId/reject'),
      headers: authHeaders,
      body: jsonEncode({
        'responseId': responseId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to reject agency offer',
    );
  }

  // 7. Create standard package booking
  static Future<Map<String, dynamic>> createStandardBooking({
    required String packageId,
  }) async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first to book a package.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: authHeaders,
      body: jsonEncode({
        'packageId': packageId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to create booking',
    );
  }

  // 8. Create customized package booking
  static Future<Map<String, dynamic>> createCustomizedBooking({
    required String customizationRequestId,
  }) async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first to book a customized package.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: authHeaders,
      body: jsonEncode({
        'customizationRequestId': customizationRequestId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to create customized booking',
    );
  }

  // 9. Retrieve logged-in user's bookings
  static Future<List<dynamic>> getMyBookings() async {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my-bookings'),
      headers: authHeaders,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['bookings'] as List<dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Failed to retrieve bookings',
    );
  }
}

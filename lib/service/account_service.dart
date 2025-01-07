import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // HTTP library
import 'package:shared_preferences/shared_preferences.dart'; // Token storage
import '../config/config_url.dart'; // Config file for base URL

class AccountService {
  // Private method to retrieve JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token is missing');
    }

    try {
      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}User/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  // Update user profile
  Future updateUserProfile(
      String initails,
      String email,
      String phone,
      DateTime? birthDay,
      String? imageUrl,
      ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token is missing');
    }

    final Map<String, dynamic> requestBody = {
      'initials': initails,
      'email': email,
      'phoneNumber': phone,
      'birthDay': birthDay?.toIso8601String(),
      'image': imageUrl,
    };

    requestBody.removeWhere((key, value) => value == null);

    try {
      final response = await http.put(
        Uri.parse('${Config_URL.baseUrl}User/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return responseData['user'];
        } else {
          throw Exception(responseData['message'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}

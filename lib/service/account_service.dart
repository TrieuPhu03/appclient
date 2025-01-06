import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config_url.dart';

class AccountService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

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
        final data = json.decode(response.body);
        if (data == null) throw Exception('Dữ liệu trống');
        return data;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  Future updateUserProfile(
    String email,
    String phone,
    DateTime birthDay,
    String? imageUrl,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token is missing');
    }

    final response = await http.put(
      Uri.parse('${Config_URL.baseUrl}User/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'phoneNumber': phone,
        'birthDay': birthDay.toIso8601String(),
        'image': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config_url.dart';

Future<void> updateUserProfile(String token, String email, String phoneNumber,
    String initials, DateTime birthDay, String imageUrl) async {
  final response = await http.put(
    Uri.parse('${Config_URL.baseUrl}User/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'Email': email,
      'PhoneNumber': phoneNumber,
      'Initials': initials,
      'BirthDay': birthDay.toIso8601String(),
      'Image': imageUrl,
    }),
  );

  if (response.statusCode == 200) {
    print('Profile updated successfully');
  } else {
    print('Failed to update profile');
  }
}

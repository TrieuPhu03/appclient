import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marker.dart';
import '../config/config_url.dart';// Define MarkerData in a separate file.

class MarkerService {
  static Future<List<MarkerData>> fetchMarkers() async {
    final response = await http.get(Uri.parse("${Config_URL.baseUrl}Marker"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((json) => MarkerData.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load markers");
    }
  }
}

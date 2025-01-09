import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/config_url.dart'; // Config baseUrl
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marker.dart';

class MarkerListScreen extends StatefulWidget {
  @override
  _MarkerListScreenState createState() => _MarkerListScreenState();
}

class _MarkerListScreenState extends State<MarkerListScreen> {
  List<MarkerData> markers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMarkers();
  }

  Future<void> fetchMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('${Config_URL.baseUrl}Admin/markers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        markers = (json.decode(response.body) as List)
            .map((data) => MarkerData.fromJson(data))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load markers: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách markers')),
      );
    }
  }

  Future<void> deleteMarker(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.delete(
      Uri.parse('${Config_URL.baseUrl}Admin/markers/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      fetchMarkers();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa marker thành công')));
    } else {
      print('Failed to delete marker: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa marker thất bại')),
      );
    }
  }

  Future<void> confirmDeleteMarker(BuildContext context, int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa marker này?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                deleteMarker(id); // Thực hiện xóa marker
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý markers', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMarkers,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : markers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_pin, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Không có marker nào.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: markers.length,
        itemBuilder: (context, index) {
          final marker = markers[index];
          return GestureDetector(
            onTap: () {
              // TODO: Navigate to marker details screen
            },
            child: Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  marker.image.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15)),
                    child: Image.network(
                      marker.image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 80),
                        );
                      },
                    ),
                  )
                      : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 80),
                  ),

                  // Details Section
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.title.isNotEmpty
                              ? marker.title
                              : 'Không có tiêu đề',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18),
                            SizedBox(width: 5),
                            Text(
                              'Kinh độ: ${marker.kinhDo}, Vĩ độ: ${marker.viDo}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                confirmDeleteMarker(context, marker.id),
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              'Xóa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

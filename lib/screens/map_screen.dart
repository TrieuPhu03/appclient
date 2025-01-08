import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/marker.dart';
import '../service/marker_service.dart';
import '../config/config_url.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String get apiUrl => "${Config_URL.baseUrl}Marker";
  WebViewController? controllerPin;
  String locationMessage = "Vui lòng cấp quyền truy cập vị trí để tiếp tục.";
  bool hasPermission = false;
  LatLng _currentLocation = LatLng(10.8550333, 106.7847033); // Default: Hutech E2
  List<MarkerData> markers = [];

  Future<void> _loadMarkers() async {
    try {
      final data = await MarkerService.fetchMarkers();
      setState(() {
        markers = data;
      });
      _buildWebView();
    } catch (e) {
      print("Failed to load markers: $e");
    }
  }

  Future<void> _addmarker(String title, String image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    String kinhDo = _currentLocation.latitude.toString();
    String viDo = _currentLocation.longitude.toString();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "UserId": "1",
          "title": title,
          "image": image,
          "kinhDo": kinhDo,
          "viDo": viDo
        }),
      );

      if (response.statusCode == 201) {
        // Load lại danh sách markers sau khi thêm thành công
        await _loadMarkers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm marker thành công!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm marker thất bại!")),
        );
      }
    } catch (e) {
      print("Error adding marker: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi gọi API!")),
      );
    }
  }

  Future<void> _checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Dịch vụ vị trí không khả dụng. Hãy bật GPS.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Quyền truy cập vị trí bị từ chối.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = "Quyền truy cập vị trí bị từ chối vĩnh viễn.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      hasPermission = true;
      _buildWebView();
    });
  }

  void _buildWebView() {
    final markersJs = markers.map((marker) {
      return '''
        { kinh: +"${marker.kinhDo}", vi: +"${marker.viDo}", title: "${marker.title}", image: "${marker.image}" }
      ''';
    }).join(",");

    controllerPin = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html lang="en" style="height: 100%; width: 100vw;">
        <head>
    <title>map</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <!-- Make sure you put this AFTER Leaflet's CSS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    <!-- <link rel="stylesheet" href="app.css"> -->
    <!-- <script src="index.js"></script> -->
</head>
        <body style="height: 100%; width: 100vw; margin: 0; padding: 0;">
          <div id="map" style="height: 100%; width: 100vw;"></div>
          <script>
            const map = L.map('map').setView([${_currentLocation.latitude}, ${_currentLocation.longitude}], 13);
            const tiles = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(map);

            const customIcon = L.icon({
              iconUrl: 'https://lh3.googleusercontent.com/d/1UDjbLyO9yulF5hxhE0N20NooFw0zyzJ5',
              iconSize: [38, 38],
              iconAnchor: [19, 38],
              popupAnchor: [0, -30]
            });

            const arrTest = [${markersJs}];
            arrTest.forEach((element) => {
              L.marker([element.kinh, element.vi], { icon: customIcon }).addTo(map)
                .bindPopup(\`
                  <div>
                    <b>\${element.title}</b><br>
                    <img src="\${element.image}" alt="\${element.title}" style="width: 150px; height: auto;">
                  </div>
                \`)
                .openPopup();
            });
          </script>
        </body>
        </html>
      ''');
  }

  void _showAddMarkerDialog() {
    final titleController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm Marker"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addmarker(titleController.text, imageController.text);
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    _loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: hasPermission
          ? WebViewWidget(controller: controllerPin!)
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(locationMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAndRequestPermission,
              child: const Text("Cấp quyền truy cập vị trí"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMarkerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
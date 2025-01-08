import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/post.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../service/add_post.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  WebViewController? controllerPin;
  String locationMessage = "Vui lòng cấp quyền truy cập vị trí để tiếp tục.";
  bool hasPermission = false;
  bool isControllersInitialized = false;
  LatLng _currentLocation = LatLng(21.0285, 105.8542);
  bool _isLoading = true;
  String _addressInfo = '';
  bool _showLocationImage = false;
  final Set<Marker> _markers = {};
  final List<Post> _posts = [];

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
      locationMessage = "Vĩ độ: ${position.latitude}, Kinh độ: ${position.longitude}";
      hasPermission = true;
      List<Map<String, double>> arrTest = [
        {'kinh': 10.855007631426592, 'vi': 106.78462463418002},
        {'kinh': 10.855805037408949, 'vi': 106.78560886338418},
        {'kinh': 10.851989481890639, 'vi': 106.78355469532497},
        {'kinh': 10.946491204232155, 'vi': 107.0107223928657}
      ];
      controllerPin = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString('''
          <!DOCTYPE html>
          <html lang="en" style="height: 100%;
    width: 100vw;">

          <head>
          <title>map</title>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
          <!-- Make sure you put this AFTER Leaflet's CSS -->
          <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
          integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
          <link rel="stylesheet" href="app.css">
          <!-- <script src="index.js"></script> -->
          </head>

          <body style="height: 100%;
    width: 100vw; padding: 0;
    margin: 0;">
          <div id="map" style="height: 100%;
    width: 100vw;"></div>
          <script>

          const map = L.map('map').setView([${position.latitude}, ${position.longitude}], 13);

          const tiles = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            }).addTo(map);

            const customIcon = L.icon({
            iconUrl: 'https://lh3.googleusercontent.com/d/1UDjbLyO9yulF5hxhE0N20NooFw0zyzJ5', // URL của icon
            iconSize: [38, 38], 
            iconAnchor: [19, 38], 
            popupAnchor: [0, -30] 
            });

            const arrTest = [{ kinh: 10.855007631426592, vi: 106.78462463418002 }, { kinh: 10.855805037408949, vi: 106.78560886338418 }, { kinh: 10.851989481890639, vi: 106.78355469532497 }, { kinh: 10.946491204232155, vi: 107.0107223928657 }]
        arrTest.forEach(element => {
            L.marker([element.kinh, element.vi], { icon: customIcon }).addTo(map)
                .bindPopup(`kinh độ: ${arrTest[0]['kinh']}, vĩ độ ${arrTest[0]['vi']}`)
                .openPopup();
            });

            </script>
            </body>
            
            </html>
        ''');

      isControllersInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // pageController = PageController(initialPage: _currentIndex);
    _checkAndRequestPermission();
    _fetchPosts();
  }
  Future<void> _fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('API_URL_Post'));
      if (response.statusCode == 200) {
        List<dynamic> postsData = json.decode(response.body);
        setState(() {
          _posts.clear();
          _posts.addAll(postsData.map((data) => Post.fromJson(data)).toList());
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }
  Future<void> _navigateToAddPost() async {
    final bool? isPostCreated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPostScreen()),
    );

    if (isPostCreated == true) {
      // Làm mới bài đăng sau khi thêm thành công
      _fetchPosts();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dịch vụ vị trí đã bị vô hiệu hóa')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quyền vị trí bị từ chối vĩnh viễn')),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy vị trí: $e')),
      );
    }
  }

  void _showLocationImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://picsum.photos/300/200',
                width: 300,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Text('Không thể tải hình ảnh: $error');
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Hình ảnh tại vị trí của bạn',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Đóng'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasPermission
          ? WebViewWidget(controller: controllerPin!) // Hiển thị bản đồ
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locationMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAndRequestPermission,
              child: const Text("Cấp quyền truy cập vị trí"),
            ),
          ],
        ),
      ),
    );
  }
}

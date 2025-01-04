import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Thêm thư viện geocoding

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Vị trí ban đầu (ví dụ: Hà Nội)
  LatLng _currentLocation = LatLng(21.0285, 105.8542);
  bool _isLoading = true;
  String _addressInfo = ''; // Biến lưu địa chỉ

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Hàm lấy địa chỉ từ tọa độ
  // Future<void> _getAddressFromCoordinates(LatLng location) async {
  //   try {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(location.latitude, location.longitude);

  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       setState(() {
  //         _addressInfo = '${place.street}, ${place.subAdministrativeArea}, '
  //             '${place.administrativeArea}, ${place.country}';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _addressInfo = 'Không thể xác định địa chỉ';
  //     });
  //   }
  // }

  // Hàm kiểm tra và yêu cầu quyền định vị
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ định vị có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dịch vụ vị trí đã bị vô hiệu hóa')),
      );
      return;
    }

    // Kiểm tra quyền
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

    // Lấy vị trí hiện tại
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Lấy địa chỉ từ tọa độ
      // await _getAddressFromCoordinates(_currentLocation);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy vị trí: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản Đồ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: MapController(),
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 80,
                          height: 80,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _addressInfo.isEmpty
                                      ? 'Vị trí hiện tại'
                                      : _addressInfo,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Hiển thị địa chỉ chi tiết ở dưới cùng
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white.withOpacity(0.8),
                    child: Text(
                      _addressInfo.isEmpty
                          ? 'Đang tìm địa chỉ...'
                          : 'Địa chỉ: $_addressInfo',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

      // Nút điều khiển
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

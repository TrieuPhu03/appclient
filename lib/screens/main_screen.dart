import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'account_screen.dart';
import './tree_screen.dart';
import 'map_screen.dart';
import 'tree_screen.dart'; // Đừng quên import SettingsScreen nếu bạn có màn hình này

// Cập nhật MainScreen để thêm điều hướng đến LogoutScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return const AccountScreen();
      case 2:
        return const MapScreen();
      case 3:
        return const SettingsScreen();
      case 4:
      default:
        return HomeScreen();
    }
  }

  Color _getIconColor(int index) {
    return _currentIndex == index ? Colors.blue : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Thêm chức năng logout tại đây
            },
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _getIconColor(0)), // Sửa thành _getIconColor(0) cho Home
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: _getIconColor(1)), // Sửa thành _getIconColor(1) cho Account
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: _getIconColor(2)), // Sửa thành _getIconColor(2) cho Map
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: _getIconColor(3)), // Sửa thành _getIconColor(3) cho Settings
            label: 'Setting',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 10,
      ),
    );
  }
}

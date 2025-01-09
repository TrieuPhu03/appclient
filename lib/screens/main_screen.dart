import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'account_screen.dart';
import './tree_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const AccountScreen(),
    const MapScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent], // Hiệu ứng gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4), // Hiệu ứng bóng đổ
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, color: Colors.white, size: 28), // Biểu tượng
            const SizedBox(width: 8),
            const Text(
              'Memory Map',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _screens[_currentIndex], // Hiển thị màn hình tương ứng
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Màu nền của thanh điều hướng
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4), // Hiệu ứng bóng đổ phía trên
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed, // Cố định để hiển thị đầy đủ nhãn
            backgroundColor: Colors.tealAccent,
            selectedItemColor: Colors.black, // Màu của mục được chọn
            unselectedItemColor: Colors.white, // Màu của mục chưa chọn
            selectedFontSize: 14, // Kích thước font của mục được chọn
            unselectedFontSize: 12, // Kích thước font của mục chưa chọn
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: Icon(Icons.home, size: 30), // Kích thước lớn hơn khi được chọn
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                activeIcon: Icon(Icons.account_circle, size: 30),
                label: 'Account',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                activeIcon: Icon(Icons.map, size: 30),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                activeIcon: Icon(Icons.settings, size: 30),
                label: 'Setting',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

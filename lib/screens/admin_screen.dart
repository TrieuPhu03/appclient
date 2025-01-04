import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nguyentrieuphu_2180601134_sunflower/screens/login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // Hàm hiển thị dialog xác nhận đăng xuất
  Future<void> _showLogoutConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Người dùng phải chọn
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng Xuất'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn đăng xuất?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
            TextButton(
              child: const Text(
                'Đăng Xuất',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                // Thực hiện đăng xuất
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Điều hướng về màn hình đăng nhập
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần chào mừng
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, Admin!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chào mừng bạn quay trở lại',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Danh sách chức năng quản trị
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminFeatureCard(
                    icon: Icons.people,
                    title: 'Quản Lý Người Dùng',
                    color: Colors.blue,
                    onTap: () {
                      // Điều hướng đến màn hình quản lý người dùng
                    },
                  ),
                  _buildAdminFeatureCard(
                    icon: Icons.settings,
                    title: 'Cài Đặt Hệ Thống',
                    color: Colors.green,
                    onTap: () {
                      // Điều hướng đến màn hình cài đặt
                    },
                  ),
                  _buildAdminFeatureCard(
                    icon: Icons.analytics,
                    title: 'Thống Kê',
                    color: Colors.orange,
                    onTap: () {
                      // Điều hướng đến màn hình thống kê
                    },
                  ),
                  _buildAdminFeatureCard(
                    icon: Icons.notifications,
                    title: 'Thông Báo',
                    color: Colors.red,
                    onTap: () {
                      // Điều hướng đến màn hình quản lý thông báo
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Nút Đăng Xuất ở dưới cùng
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _showLogoutConfirmDialog(context),
          child: const Text(
            'Đăng Xuất',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Widget tạo card chức năng (giữ nguyên)
  Widget _buildAdminFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

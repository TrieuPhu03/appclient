import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/ThemeNotifier.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'Tiếng Việt';
  String _storedPassword = ""; // Biến để lưu mật khẩu đã đăng nhập

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Tải trạng thái chế độ sáng/tối khi màn hình được tạo
    _loadPassword(); // Lấy mật khẩu từ SharedPreferences
  }

  // Hàm tải mật khẩu từ SharedPreferences
  void _loadPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPassword =
          prefs.getString('password') ?? ''; // Lấy mật khẩu đã lưu
    });
  }

  // Hàm tải trạng thái chế độ sáng/tối từ SharedPreferences
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('isDarkMode') ??
          false; // Mặc định là false (chế độ sáng)
    });
  }

  // Hàm lưu trạng thái chế độ sáng/tối vào SharedPreferences
  void _saveTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode); // Lưu trạng thái chế độ sáng/tối
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.blue[400],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[400]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Cài đặt chung'),
          _buildSwitchTile(
            'Chế độ tối',
            'Bật hoặc tắt chế độ tối.',
            _darkMode,
            (value) {
              setState(() {
                _darkMode = value;
              });
              _saveTheme(value); // Lưu trạng thái chế độ sáng/tối
              // Cập nhật theme khi thay đổi chế độ
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          _buildSwitchTile(
            'Thông báo',
            'Nhận thông báo từ ứng dụng.',
            _notifications,
            (value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Tài khoản'),
          ListTile(
            leading: const Icon(Icons.key, color: Colors.orange),
            title: const Text('Thay đổi mật khẩu'),
            onTap: _showChangePasswordDialog,
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Giới thiệu ứng dụng'),
            onTap: () {
              _showInfoDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất'),
            onTap: () {
              _showLogoutDialog();
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Ngôn ngữ'),
          _buildLanguageDropdown(),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<String>(
      value: _language,
      onChanged: (String? newValue) {
        setState(() {
          _language = newValue!;
        });
      },
      items: <String>['Tiếng Việt', 'English', 'Français', 'Deutsch']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      activeColor: Colors.blue[400],
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showChangePasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thay đổi mật khẩu'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu hiện tại',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu mới',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final currentPassword =
                              _currentPasswordController.text;
                          final newPassword = _newPasswordController.text;
                          final confirmPassword =
                              _confirmPasswordController.text;

                          if (newPassword != confirmPassword) {
                            _showErrorDialog(
                                'Mật khẩu mới và xác nhận không khớp.');
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await _changePassword(currentPassword, newPassword);
                            Navigator.pop(context);
                            _showSuccessDialog(
                                'Mật khẩu đã được thay đổi thành công.');
                          } catch (e) {
                            _showErrorDialog(e.toString());
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Hàm gửi yêu cầu thay đổi mật khẩu đến API backend
  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("Bạn chưa đăng nhập.");
    }

    final response = await http.post(
      Uri.parse('${Config_URL.baseUrl}authenticate/change-password'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      final error =
          jsonDecode(response.body)['errors'] ?? "Yêu cầu không hợp lệ.";
      throw Exception(error);
    } else if (response.statusCode == 401) {
      throw Exception("Bạn chưa đăng nhập hoặc phiên đăng nhập đã hết hạn.");
    } else {
      throw Exception("Lỗi không xác định. Vui lòng thử lại sau.");
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Giới thiệu ứng dụng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/1.png', // Đường dẫn tới ảnh
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đây là ứng dụng định vị ghi lại hành trình bạn đã đi qua.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ứng dụng hỗ trợ bạn theo dõi, lưu trữ và quản lý hành trình tiện lợi với các tính năng chính:\n\n'
                  '- Ghi lại vị trí và hành trình\n'
                  '- Chuyển đổi giữa chế độ sáng và tối\n'
                  '- Cài đặt ngôn ngữ theo ý muốn\n'
                  '- Quản lý tài khoản và bảo mật\n\n'
                  'Cảm ơn bạn đã tin tưởng sử dụng ứng dụng của chúng tôi!',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // Đóng hộp thoại mà không làm gì
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove(
                    'jwt_token'); // Xóa token đã lưu trong SharedPreferences

                Navigator.pop(context); // Đóng hộp thoại đăng xuất

                // Hiển thị thông báo thành công
                _showSuccessDialog('Bạn đã đăng xuất thành công.');

                // Chuyển hướng người dùng về màn hình đăng nhập
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Màu nền đỏ cho nút
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thành công'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Tải trạng thái chế độ sáng/tối từ SharedPreferences
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Lưu trạng thái chế độ sáng/tối vào SharedPreferences
  void _saveTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  // Hàm gửi yêu cầu thay đổi mật khẩu đến API backend
  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    const apiUrl =
        "https://goodtealboat31.conveyor.cloud/api/authenticate/change-password";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("Bạn chưa đăng nhập.");
    }

    final response = await http.post(
      Uri.parse(apiUrl),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        actions: [
          Switch(
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              _saveTheme(value);
            },
          ),
        ],
      ),
      body: Container(
        color: _darkMode ? Colors.black : Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: Icon(Icons.key,
                  color: _darkMode ? Colors.orangeAccent : Colors.orange),
              title: Text(
                'Thay đổi mật khẩu',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black),
              ),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              leading: Icon(Icons.logout,
                  color: _darkMode ? Colors.redAccent : Colors.red),
              title: Text(
                'Đăng xuất',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black),
              ),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
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
              backgroundColor: _darkMode ? Colors.black : Colors.white,
              title: Text(
                'Thay đổi mật khẩu',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      style: TextStyle(
                          color: _darkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu hiện tại',
                        labelStyle: TextStyle(
                            color: _darkMode ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      style: TextStyle(
                          color: _darkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        labelStyle: TextStyle(
                            color: _darkMode ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(
                          color: _darkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        labelStyle: TextStyle(
                            color: _darkMode ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                        color: _darkMode ? Colors.white : Colors.black),
                  ),
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
                      : Text(
                          'Lưu',
                          style: TextStyle(
                              color: _darkMode ? Colors.white : Colors.black),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _darkMode ? Colors.black : Colors.white,
          title: Text(
            'Đăng xuất',
            style: TextStyle(color: _darkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất không?',
            style:
                TextStyle(color: _darkMode ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt_token');

                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          backgroundColor: _darkMode ? Colors.black : Colors.white,
          title: Text(
            'Lỗi',
            style: TextStyle(color: _darkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            message,
            style:
                TextStyle(color: _darkMode ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black),
              ),
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
          backgroundColor: _darkMode ? Colors.black : Colors.white,
          title: Text(
            'Thành công',
            style: TextStyle(color: _darkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            message,
            style:
                TextStyle(color: _darkMode ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

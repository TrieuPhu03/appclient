import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config_url.dart';
import '../service/api_client.dart';
import '../models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final ApiClient _apiClient;
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  User? _currentUser;
  bool _isLoading = false;
  String? _currentUserId;

  _AddPostScreenState() : _apiClient = ApiClient(baseUrl: Config_URL.baseUrl);

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  // Hàm tải userId từ SharedPreferences
  Future<void> _loadCurrentUserId() async {
    var prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');

    if (username != null) {
      setState(() {
        _currentUserId = username;
      });
    }
  }

  // Hàm lấy thông tin người dùng từ API
  Future<void> _fetchUserById(String userId) async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}User'));

      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);
        var user = users.firstWhere(
            (user) =>
                user['userName'].toString().toLowerCase() ==
                userId.toLowerCase(),
            orElse: () => null);

        if (user != null) {
          setState(() {
            _currentUser = User.fromJson(user);
          });
        } else {
          print('User not found');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Hàm lưu userId (gọi khi đăng nhập thành công)
  Future<void> saveUserId(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token); // Lưu token
    print('JWT Token saved');
  }

  // Hàm tạo bài đăng
  Future<void> addPost(BuildContext context) async {
    if (_contentController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final username = prefs.getString('username');

      if (token == null || username == null) {
        print('Token or username not found in SharedPreferences');
        throw Exception('Thông tin người dùng không tồn tại');
      }

      print('Token: $token');
      print('Username: $username');

      final post = {
        'description': _contentController.text.trim(),
        'image': _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
        'like': 0,
        'userId': username,
        'user': null,
        'comment': null,
        'createdAt': DateTime.now().toIso8601String()
      };

      print('Creating post: $post');

      final response = await http.post(Uri.parse('${Config_URL.baseUrl}Post'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode(post));

      print('Post request response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Lỗi tạo bài đăng: ${response.body}');
      }
    } catch (e) {
      print('Error in addPost: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Bài Đăng Mới'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung bài đăng',
                      hintText: 'Nhập nội dung...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Hình ảnh (Tùy chọn)',
                      hintText: 'Nhập URL hình ảnh',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => addPost(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Đăng Bài',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';
import '../config/config_url.dart';
import '../service/api_client.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final ApiClient _apiClient;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  bool isLoading = false;

  _EditPostScreenState() : _apiClient = ApiClient(baseUrl: Config_URL.baseUrl);

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.description);
    _imageUrlController = TextEditingController(text: widget.post.image ?? '');
  }

  // Xác thực input
  bool _validateInputs() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bài đăng!'),
        ),
      );
      return false;
    }
    return true;
  }

  // Hàm chỉnh sửa bài đăng
  Future<void> editPost() async {
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Chuẩn bị dữ liệu để gửi lên server
      final Map<String, dynamic> postData = {
        'id': widget.post.id,
        'userId': widget.post.userId,
        'description': _contentController.text.trim(),
        'image': _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        'like': widget.post.like,
      };

      // Thực hiện PUT request để chỉnh sửa bài đăng
      final response = await http.put(
        Uri.parse(
            '${Config_URL.baseUrl}Post/${widget.post.id}'), // Sử dụng Config_URL
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Cập nhật thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bài đăng đã được cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Không thể cập nhật bài đăng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật bài đăng: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      appBar: AppBar(title: const Text('Chỉnh Sửa Bài Đăng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung bài đăng',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Hình ảnh (Tùy chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: editPost,
                    child: const Text('Cập nhật bài đăng'),
                  ),
          ],
        ),
      ),
    );
  }
}

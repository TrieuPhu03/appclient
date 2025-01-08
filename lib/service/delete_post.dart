import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../service/api_client.dart';

class DeletePostScreen extends StatefulWidget {
  final int postId;
  final Function onDeleteSuccess;
  final String baseUrl = '${Config_URL.baseUrl}Post';

  DeletePostScreen({
    Key? key,
    required this.postId,
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  _DeletePostScreenState createState() => _DeletePostScreenState();
}

class _DeletePostScreenState extends State<DeletePostScreen> {
  bool isLoading = false;
  final ApiClient _apiClient;

  _DeletePostScreenState()
      : _apiClient = ApiClient(baseUrl: Config_URL.baseUrl);

  Future<void> deletePost(BuildContext context) async {
    setState(() {
      isLoading = true; // Đánh dấu đang xử lý
    });

    final response =
        await http.delete(Uri.parse('${widget.baseUrl}/${widget.postId}'));

    setState(() {
      isLoading = false; // Kết thúc xử lý
    });

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully!')),
      );
      widget.onDeleteSuccess(); // Gọi callback để làm mới danh sách bài đăng
      Navigator.pop(context, true); // Quay lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete post: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Post')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Hiển thị loader khi đang xử lý
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Are you sure you want to delete this post?'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => deletePost(context),
                    child: const Text('Delete'),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';
import '../service/add_post.dart'; // Import màn hình thêm bài đăng
import '../service/edit_post.dart';
import '../service/delete_post.dart';
import '../config/config_url.dart';
import 'dart:io';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> _posts;
  late Future<List<User>> _users;
  final TextEditingController _searchController = TextEditingController();
  List<Post> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() {
    setState(() {
      _posts = fetchPosts();
      _users = fetchUsers();
    });
    return Future.wait([_posts, _users]);
  }

  // Thêm phương thức điều hướng đến màn hình thêm bài đăng
  void _navigateToAddPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPostScreen(),
      ),
    );

    // Nếu thêm bài đăng thành công, làm mới danh sách
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEditPost(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: post),
      ),
    );

    // Kiểm tra xem có sự thay đổi dữ liệu hay không (result có thể là true nếu bài đăng đã được chỉnh sửa)
    if (result == true) {
      _loadData(); // Tải lại dữ liệu sau khi chỉnh sửa
    }
  }

  void _editPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: post),
      ),
    );
  }

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}Post'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final posts = data.map((item) => Post.fromJson(item)).toList();

        // Khởi tạo filteredPosts ban đầu
        setState(() {
          _filteredPosts = posts;
        });

        return posts;
      } else {
        throw Exception('Lỗi tải bài đăng: ${response.statusCode}');
      }
    } catch (e) {
      print('Chi tiết lỗi tải bài đăng: $e');
      rethrow;
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}User'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi tải người dùng: ${response.statusCode}');
      }
    } catch (e) {
      print('Chi tiết lỗi tải người dùng: $e');
      rethrow;
    }
  }

  void _filterPosts(String query) {
    _posts.then((posts) {
      setState(() {
        _filteredPosts = posts.where((post) {
          return post.description
              ?.toLowerCase()
              .contains(query.toLowerCase()) ??
              false;
        }).toList();
      });
    });
  }

  Future<void> _deletePost(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DeletePostScreen(
              postId: post.id!,
              onDeleteSuccess: () {
                _loadData();
              },
            ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: Icon(Icons.home, color: Colors.teal, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: Text(
                  'Trang chủ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
            onPressed: _loadData,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            onPressed: _navigateToAddPost,
            tooltip: 'Thêm bài đăng mới',
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (postSnapshot.hasError) {
            return _buildErrorState(
              context,
              message: 'Không thể tải bài đăng',
              error: postSnapshot.error,
              onRetry: _loadData,
            );
          }

          return FutureBuilder<List<User>>(
            future: _users,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return _buildErrorState(
                  context,
                  message: 'Không thể tải người dùng',
                  error: userSnapshot.error,
                  onRetry: _loadData,
                );
              }

              final posts = _filteredPosts;
              final users = userSnapshot.data ?? [];

              if (posts.isEmpty) {
                return _buildEmptyState(
                  context,
                  message: 'Không có bài đăng',
                  suggestion: 'Hãy thử tạo bài đăng mới',
                );
              }

              return CustomScrollView(
                slivers: [
                  _buildPostList(posts, users, screenWidth),
                ],
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildErrorState(BuildContext context, {
    required String message,
    Object? error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.redAccent),
          ),
          if (error != null)
            Text(
              'Lỗi: $error',
              style: TextStyle(color: Colors.grey),
            ),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor : Colors.blueAccent),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {
    required String message,
    required String suggestion,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.post_add, color: Colors.grey, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
          ),
          Text(
            suggestion,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(List<Post> posts, List<User> users, double screenWidth) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = posts[index];
          final user = users.firstWhere(
                (u) => u.id == post.userId,
            orElse: () => User(
              id: null,
              userName: 'Người dùng ẩn',
              email: '',
              passwordHash: '',
            ),
          );

          return _PostCard(
            post: post,
            user: user,
            screenWidth: screenWidth,
            onEdit: () => _navigateToEditPost(post),
            onDelete: () => _deletePost(post),
          );
        },
        childCount: posts.length,
      ),
    );
  }
}
class _PostCard extends StatelessWidget {
  final Post post;
  final User user;
  final double screenWidth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.user,
    required this.screenWidth,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02, horizontal: screenWidth * 0.02),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với avatar và username
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                      ? FileImage(File(user.avatar!)) // Dùng FileImage cho hình ảnh từ file cục bộ
                      : const NetworkImage(
                      'https://picsum.photos/seed/default/200/200') as ImageProvider,
                  radius: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(); // Gọi hàm _editPost được truyền từ HomeScreen
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xoá'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nội dung bài post
          if (post.description?.isNotEmpty ?? false)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              child: Text(
                post.description ?? '',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),

          // Hình ảnh nếu có
          if (post.image != null && post.image!.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: screenWidth * 0.8,
              ),
              child: Image.network(
                post.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error_outline),
                    ),
                  );
                },
              ),
            ),
          // Phần tương tác (like, comment, share)
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInteractionButton(
                  icon: Icons.thumb_up_outlined,
                  label: 'Like',
                  count: post.like,
                  onTap: () {},
                ),
                _buildInteractionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () {},
                ),
                _buildInteractionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenWidth * 0.01,
        ),
        child: Row(
          children: [
            Icon(icon, size: screenWidth * 0.05, color: Colors.grey[600]),
            SizedBox(width: screenWidth * 0.01),
            Text(
              count != null ? '$label ($count)' : label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

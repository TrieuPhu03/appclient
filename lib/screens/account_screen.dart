import 'package:flutter/material.dart';
import '../service/account_service.dart';
import 'edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountService _accountService = AccountService();
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _accountService.getProfile();
  }

  String _formatDate(String? date) {
    // Thêm dấu ? để chấp nhận giá trị null
    if (date == null || date.isEmpty) return 'Không có';
    try {
      final dateTime = DateTime.parse(date);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return 'Không có';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image (use avatar from API)
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: user['image'] != null
                        ? NetworkImage(user['image']) // Use avatar URL from API
                        : const AssetImage('assets/nguoidung.jpg')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 20),

                  // User Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                              Icons.person, 'Tên', user['userName']),
                          const Divider(),
                          _buildDetailRow(Icons.email, 'Email', user['email']),
                          const Divider(),
                          _buildDetailRow(Icons.phone, 'Số Điện Thoại',
                              user['phoneNumber'] ?? 'Không có'),
                          const Divider(),
                          _buildDetailRow(Icons.cake, 'Ngày sinh',
                              _formatDate(user['birthDay'])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button to edit profile
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the profile edit screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    child: const Text('Chỉnh sửa thông tin'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to create consistent detail rows
  Widget _buildDetailRow(IconData icon, String label, String? value) {
    // Thêm ? cho value
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(value ?? 'Không có',
                  style: const TextStyle(fontSize: 16)), // Thêm ?? operator
            ],
          ),
        ],
      ),
    );
  }
}

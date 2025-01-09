import 'package:flutter/material.dart';
import '../service/account_service.dart';
import 'edit_profile_screen.dart';
import 'dart:io';

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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không có';
    return "${date.day}-${date.month}-${date.year}";
  }

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: Icon(Icons.person, color: Colors.teal, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: Text(
                  'Trang cá nhân',
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final user = await _userFuture;
              DateTime? birthDay = user['birthDay'] != null
                  ? DateTime.parse(user['birthDay'])
                  : null;

              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    email: user['email'] ?? '',
                    phone: user['phoneNumber'] ?? '',
                    initials: user['initials'] ?? '',
                    birthDay: birthDay,
                    image: user['image'],
                  ),
                ),
              );

              if (updated == true) {
                setState(() {
                  _userFuture = _accountService.getProfile();
                });
              }
            },
          ),
        ],
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

          DateTime? birthDay = user['birthDay'] != null
              ? DateTime.parse(user['birthDay'])
              : null;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: user['image'] != null
                        ? FileImage(File(user['image']))  // Đọc hình ảnh từ file cục bộ
                        : const AssetImage('assets/nguoidung.jpg') as ImageProvider,
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.teal.shade200,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.1),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                              Icons.person, 'Tên', user['initials']),
                          const Divider(),
                          _buildDetailRow(Icons.email, 'Email', user['email']),
                          const Divider(),
                          _buildDetailRow(Icons.phone, 'Số Điện Thoại',
                              user['phoneNumber'] ?? 'Không có'),
                          const Divider(),
                          _buildDetailRow(Icons.cake, 'Ngày sinh',
                              _formatDate(birthDay)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey)),
              Text(value ?? 'Không có', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

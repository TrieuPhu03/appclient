import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/account_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AccountService _accountService = AccountService();

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _initialsController;
  late TextEditingController _birthDayController;
  late File? _imageFile;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _initialsController = TextEditingController();
    _birthDayController = TextEditingController();
    _imageFile = null;
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image selection or display
              Center(
                child: GestureDetector(
                  onTap: _selectImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/nguoidung.jpg')
                            as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : Container(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Phone field
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Initials field
              TextField(
                controller: _initialsController,
                decoration: const InputDecoration(
                  labelText: 'Tên viết tắt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Birth day field
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    locale: const Locale('vi', 'VN'),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthDayController.text = picked.toIso8601String();
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _birthDayController,
                    decoration: const InputDecoration(
                      labelText: 'Ngày sinh',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () async {
                    try {
                      DateTime? birthDay;
                      try {
                        birthDay = DateTime.parse(_birthDayController.text);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Ngày sinh không hợp lệ')),
                        );
                        return;
                      }

                      await _accountService.updateUserProfile(
                        _emailController.text,
                        _phoneController.text,
                        birthDay,
                        _imageFile?.path,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cập nhật thành công')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi cập nhật: $e')),
                      );
                    }
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _initialsController.dispose();
    _birthDayController.dispose();
    super.dispose();
  }
}

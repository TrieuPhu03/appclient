import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/account_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String email;
  final String phone;
  final String initials;
  final DateTime? birthDay;
  final String? image;

  EditProfileScreen({
    required this.email,
    required this.phone,
    required this.initials,
    required this.birthDay,
    this.image,
  });

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
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _initialsController = TextEditingController(text: widget.initials);
    _birthDayController = TextEditingController(
      text: widget.birthDay != null
          ? _formatDateForDisplay(widget.birthDay)
          : 'Không có',
    );
    _imageFile = null;
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return 'Không có';
    return "${date.day}-${date.month}-${date.year}";
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

  Future<DateTime?> _parseDateString(String dateStr) {
    if (dateStr.isEmpty || dateStr == 'Không có') return Future.value(null);

    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length == 3) {
        return Future.value(DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0])  // day
        ));
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return Future.value(null);
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
              Center(
                child: GestureDetector(
                  onTap: _selectImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : widget.image != null
                        ? NetworkImage(widget.image!)
                        : const AssetImage('assets/nguoidung.jpg')
                    as ImageProvider,
                    child: _imageFile == null && widget.image == null
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _initialsController,
                decoration: const InputDecoration(
                  labelText: 'Tên viết tắt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: widget.birthDay ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthDayController.text = _formatDateForDisplay(picked);
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () async {
                    try {
                      final DateTime? selectedBirthDay =
                      await _parseDateString(_birthDayController.text);
                      await _accountService.updateUserProfile(
                        _initialsController.text,
                        _emailController.text,
                        _phoneController.text,
                        selectedBirthDay, // Bỏ dấu ! vì đã cho phép null
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
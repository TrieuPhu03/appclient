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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, color: Colors.white, size: 28), // Biểu tượng
              const SizedBox(width: 8),
              const Text(
                'Chỉnh sửa thông tin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hình ảnh đại diện
              Center(
                child: GestureDetector(
                  onTap: _selectImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : widget.image != null
                            ? NetworkImage(widget.image!)
                            : const AssetImage('assets/nguoidung.jpg')
                        as ImageProvider,
                        child: _imageFile == null && widget.image == null
                            ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                            : null,
                      ),
                      if (_imageFile == null && widget.image == null)
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.black38,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Trường nhập liệu Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 10),

              // Trường nhập liệu Số điện thoại
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone,
              ),
              const SizedBox(height: 10),

              // Trường nhập liệu Tên viết tắt
              _buildTextField(
                controller: _initialsController,
                label: 'Tên viết tắt',
                icon: Icons.person,
              ),
              const SizedBox(height: 10),

              // Trường nhập liệu Ngày sinh
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
                  child: _buildTextField(
                    controller: _birthDayController,
                    label: 'Ngày sinh',
                    icon: Icons.calendar_today,
                    isDateField: true,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Nút lưu thay đổi
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final DateTime? selectedBirthDay =
                      await _parseDateString(_birthDayController.text);
                      await _accountService.updateUserProfile(
                        _initialsController.text,
                        _emailController.text,
                        _phoneController.text,
                        selectedBirthDay,
                        _imageFile?.path,
                      );

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cập nhật thành công')),
                      );
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi cập nhật: $e')),
                      );
                    }
                  },
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDateField = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: isDateField,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
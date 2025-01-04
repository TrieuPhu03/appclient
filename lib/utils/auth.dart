import '../service/auth_service.dart';
import '../service/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Auth {
  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();

  // Đăng nhập
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    var result = await _authService.login(username, password);
    return result; // returns a map with {success: bool, token: string?, role: string?, message: string?}
  }

  // Đăng ký tài khoản mới
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String initials,
    required String role,
  }) async {
    // Tạo body để gửi lên API
    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "initials": initials,
      "role": role,
    };

    // Gọi API đăng ký thông qua ApiClient
    try {
      var response = await _apiClient.post('Authenticate/register', body: body);

      // Xử lý kết quả từ API
      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);
        return result;
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại, vui lòng thử lại.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Đăng xuất
  static Future<Map<String, dynamic>> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Kiểm tra token có tồn tại không
      if (await prefs.containsKey('jwt_token')) {
        await prefs.remove('jwt_token');
      }

      return {"success": true, "message": "Đăng xuất thành công."};
    } catch (e) {
      return {
        "success": false,
        "message": "Lỗi khi đăng xuất: ${e.toString()}"
      };
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // VPS = "https://kelompok9.my.id/api"
  // Lokal = http://10.0.2.2:8000/api
  static const String baseUrl = "https://kelompok9.my.id/api";

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['user'] ?? data;
      }
      return null;
    } catch (e) {
      print("Error Profile: $e");
      return null;
    }
  }
  //  NOTIFIKASI
  static Future<List<dynamic>> getNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error Fetch Notifications: $e");
      return [];
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print("Error Fetch Unread Count: $e");
      return 0;
    }
  }

  static Future<bool> markNotificationAsRead(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Mark as Read: $e");
      return false;
    }
  }

  static Future<bool> updateProfile(
    String nama,
    String tglLahir,
    String gender,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tokenLogin = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenLogin',
        },
        body: {
          'username': nama,
          'tanggal_lahir': tglLahir,
          'jenis_kelamin': gender,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Update Profile: $e");
      return false;
    }
  }

  static Future<bool> resetPassword(
    String phone,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {'Accept': 'application/json'},
        body: {'no_hp': phone, 'otp': otp, 'new_password': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Reset Password: $e");
      return false;
    }
  }

  static Future<bool> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tokenLogin = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenLogin',
        },
        body: {'old_password': oldPassword, 'new_password': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Change Password: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getMedicines({
    String? search,
    int? kategoriId,
  }) async {
    try {
      String url = '$baseUrl/obats?';
      if (search != null) url += 'search=$search&';
      if (kategoriId != null) url += 'kategori_id=$kategoriId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error Fetch Medicines: $e");
      return [];
    }
  }

  static Future<bool> checkout(
    List<Map<String, dynamic>> cartItems,
    String paymentMethod,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return false;

      Map<String, dynamic> payload = {
        'items': cartItems
            .map(
              (item) => {
                'obat_id': item['id'],
                'qty': item['qty'],
                'harga': item['harga'],
              },
            )
            .toList(),
        'payment_method': paymentMethod,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/orders/checkout"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error Checkout: $e");
      return false;
    }
  }

  static Future<String?> loginPembeli(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login-pembeli"),
        headers: {'Accept': 'application/json'},
        body: {'no_hp': phone, 'password': password},
      );

      if (response.statusCode == 200) {
        String token = json.decode(response.body)['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token;
      }
      return null;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  static Future<bool> registerPembeli(
    String name,
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register-pembeli"),
        headers: {'Accept': 'application/json'},
        body: {'username': name, 'no_hp': phone, 'password': password},
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error Register: $e");
      return false;
    }
  }

  // Request OTP
  static Future<bool> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/request-otp"),
        headers: {'Accept': 'application/json'},
        body: {'no_hp': phone},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Request OTP: $e");
      return false;
    }
  }

  static Future<bool> uploadPrescription(String filePath, String obatId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/prescriptions/upload"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['obat_id'] = obatId;
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error Upload: $e");
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //Sesuaikan IP dan Port
  static const String baseUrl = "http://10.0.2.2:8000/api";

  //Profil
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

  // Update Profil
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
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'username': nama,
          'tanggal_lahir': tglLahir,
          'jenis_kelamin': gender,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal Update: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Update Profile: $e");
      return false;
    }
  }

  // Daftar Obat
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
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      print("Error Fetch Medicines: $e");
      return [];
    }
  }

  //Checkout Keranjang
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

  //Request OTP
  static Future<bool> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/request-otp"),
        headers: {'Accept': 'application/json'},
        body: {'no_hp': phone},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. Verify OTP
  static Future<String?> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login-pembeli"),
        headers: {'Accept': 'application/json'},
        body: {'no_hp': phone, 'otp': otp},
      );

      if (response.statusCode == 200) {
        String token = json.decode(response.body)['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //Upload Foto Resep
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

      print("=== DEBUG UPLOAD RESEP ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error Upload: $e");
      return false;
    }
  }
}

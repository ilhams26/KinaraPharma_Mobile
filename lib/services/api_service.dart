import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<bool> requestOtp(String phone) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/request-otp",
      ), 
      body: {'phone': phone},
    );

    if (response.statusCode == 200) {

      print("OTP Response: ${response.body}");
      return true;
    } else {
      print("Request OTP Gagal: ${response.body}");
      return false;
    }
  }

  // 2. Verifikasi OTP & Ambil Token JWT
  static Future<String?> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login-pembeli"), 
      body: {'phone': phone, 'otp': otp},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['token'];

      // Simpan Token JWT 
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
    } else {
      print("Verifikasi OTP Gagal: ${response.body}");
      return null;
    }
  }
}

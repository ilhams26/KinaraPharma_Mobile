import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Service API Mobile
//192.168.1.103
class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<bool> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/request-otp"),
      
        headers: {'Accept': 'application/json'},
        body: {'no_hp': phone},
      );

      print("===== DEBUG API =====");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("=====================");

      return response.statusCode == 200;
    } catch (e) {
      print("KONEKSI ERROR: $e");
      return false;
    }
  }

  static Future<String?> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login-pembeli"),
        headers: {
          'Accept': 'application/json',
        }, 
        body: {'no_hp': phone, 'otp': otp},
      );

      print("===== DEBUG VERIFY OTP =====");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("============================");

      if (response.statusCode == 200) {
        String token = json.decode(response.body)['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token;
      }
      return null;
    } catch (e) {
      print("ERROR VERIFY: $e");
      return null;
    }
  }
}

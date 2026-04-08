import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Service API Mobile
class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<bool> requestOtp(String phone) async {
    final response = await http.post(
      Uri.parse("$baseUrl/request-otp"),
      body: {'no_hp': phone},
    );
    return response.statusCode == 200;
  }

  static Future<String?> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login-pembeli"),
      body: {'no_hp': phone, 'otp': otp},
    );

    if (response.statusCode == 200) {
      String token = json.decode(response.body)['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    }
    return null;
  }
}

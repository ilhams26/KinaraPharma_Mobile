import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/midtrans_screen.dart';

class OrderService {
  static Future<bool> prosesCheckoutReal(
    BuildContext context,
    String tokenLogin,
    List<Map<String, dynamic>> keranjang,
  ) async {
    // GANTI SESUAI URL NGROK KAMU
    final String apiUrl =
        'https://deon-experimental-dalton.ngrok-free.dev/api/midtrans/checkout';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenLogin',
        },
        body: jsonEncode({'items': keranjang}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String snapToken = data['snap_token'];
        final String orderCode = data['order_code'];

        // Pindah ke layar Midtrans, lalu tunggu pembeli menutup halamannya
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidtransPaymentScreen(
              snapToken: snapToken,
              orderCode: orderCode,
            ),
          ),
        );

        // Jika pembeli selesai dan halaman tertutup (result = true)
        if (result == true) {
          return true;
        }
        return false;
      } else {
        // Jika Laravel membalas error (misal stok habis)
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout Gagal: ${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Jika internet mati atau Ngrok salah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kesalahan jaringan: Cek koneksi atau URL Ngrok Anda.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

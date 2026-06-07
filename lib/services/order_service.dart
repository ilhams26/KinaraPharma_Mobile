import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/midtrans_screen.dart';
import '../services/cart_service.dart';

class OrderService {
  static Future<bool> prosesCheckoutReal(
    BuildContext context,
    String tokenLogin,
    List<Map<String, dynamic>> keranjang,
  ) async {
    final String apiUrl = 'https://kelompok9.my.id/api/midtrans/checkout';

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

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidtransPaymentScreen(
              snapToken: snapToken,
              orderCode: orderCode,
            ),
          ),
        );

        if (result == true) {
          // BERSIHKAN KERANJANG 
          final currentCart = await CartService.getCart();
          final boughtIds = keranjang
              .map((e) => e['obat_id'].toString())
              .toList();

          currentCart.removeWhere(
            (item) => boughtIds.contains(item['id'].toString()),
          );
          await CartService.saveCart(currentCart);

          return true;
        }
        return false;
      } else {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi Kesalahan : Cek koneksi atau URL Anda.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

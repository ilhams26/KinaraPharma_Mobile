import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'kinara_cart';

  static Future<void> addToCart(Map<String, dynamic> obat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartStringList = prefs.getStringList(_cartKey) ?? [];

    List<Map<String, dynamic>> cartItems = cartStringList
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .toList();

    int index = cartItems.indexWhere((item) => item['id'] == obat['id']);

    int maxStok = obat['stok_total'] ?? 999;

    if (index != -1) {
      if (cartItems[index]['qty'] < maxStok) {
        cartItems[index]['qty'] += 1;
      }
    } else {
      cartItems.add({
        'id': obat['id'],
        'nama': obat['nama'] ?? obat['nama_obat'],
        'harga': obat['harga'],
        'qty': 1,
        'stok_total': maxStok,
        'selected': true,
      });
    }

    List<String> updatedCartString = cartItems
        .map((e) => json.encode(e))
        .toList();
    await prefs.setStringList(_cartKey, updatedCartString);
  }

  static Future<List<Map<String, dynamic>>> getCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartStringList = prefs.getStringList(_cartKey) ?? [];
    return cartStringList
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedCartString = cartItems
        .map((e) => json.encode(e))
        .toList();
    await prefs.setStringList(_cartKey, updatedCartString);
  }
}

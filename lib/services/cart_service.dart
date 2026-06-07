import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'kinara_cart';

  static Future<void> addToCart(Map<String, dynamic> obat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartStringList = prefs.getStringList(_cartKey) ?? [];

    List<Map<String, dynamic>> cartItems = [];
    for (var str in cartStringList) {
      try {
        cartItems.add(Map<String, dynamic>.from(json.decode(str)));
      } catch (e) {

        continue;
      }
    }


    int maxStok = 999;
    if (obat['stok_total'] != null) {
      maxStok = int.tryParse(obat['stok_total'].toString()) ?? 999;
    }

    int index = cartItems.indexWhere(
      (item) => item['id'].toString() == obat['id'].toString(),
    );

    if (index != -1) {

      int currentQty = int.tryParse(cartItems[index]['qty'].toString()) ?? 1;
      if (currentQty < maxStok) {
        cartItems[index]['qty'] = currentQty + 1;
      }
    } else {
      cartItems.add({
        'id': obat['id'],
        'nama': obat['nama'] ?? obat['nama_obat'] ?? 'Tanpa Nama',
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

    List<Map<String, dynamic>> cartItems = [];
    for (var str in cartStringList) {
      try {
        cartItems.add(Map<String, dynamic>.from(json.decode(str)));
      } catch (e) {}
    }
    return cartItems;
  }

  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedCartString = cartItems
        .map((e) => json.encode(e))
        .toList();
    await prefs.setStringList(_cartKey, updatedCartString);
  }
  static Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy data sekarang punya atribut "selected"
  List<Map<String, dynamic>> cartItems = [
    {
      "id": 1,
      "nama": "Panadol Extra 500mg",
      "harga": 12500,
      "qty": 2,
      "selected": true,
    },
    {
      "id": 2,
      "nama": "Vitamin C IPI",
      "harga": 8000,
      "qty": 1,
      "selected": false,
    },
  ];

  int get totalHarga {
    int total = 0;
    for (var item in cartItems) {
      if (item['selected'] == true) {
        int hrg = double.tryParse(item['harga'].toString())?.toInt() ?? 0;
        int qty = int.tryParse(item['qty'].toString()) ?? 1;
        total += hrg * qty;
      }
    }
    return total;
  }

  String formatRupiah(dynamic price) {
    int value = double.tryParse(price.toString())?.toInt() ?? 0;
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ngecek apakah ada minimal 1 barang yang dicentang untuk menyalakan tombol Checkout
    bool hasSelectedItems = cartItems.any((item) => item['selected'] == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Keranjangmu masih kosong",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                bool isSelected = item['selected'] ?? false;

                // Membungkus Card agar bisa di-klik di area mana saja untuk menceklis
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      item['selected'] = !isSelected;
                    });
                  },
                  child: Card(
                    color: isDark ? const Color(0xFF1B3B22) : Colors.white,
                    // Efek melayang lebih tinggi jika dipilih
                    elevation: isSelected ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        // 🚨 UI BARU: BORDER HIJAU MENYALA JIKA DIPILIH
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C5535)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.medication,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Rp ${formatRupiah(item['harga'])}",
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  if (item['qty'] > 1) {
                                    setState(() => item['qty']--);
                                  } else {
                                    setState(() => cartItems.removeAt(index));
                                  }
                                },
                              ),
                              Text(
                                "${item['qty']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() => item['qty']++);
                                },
                              ),
                              const SizedBox(width: 8),
                              // 🚨 UI BARU: ICON CENTANG DI KANAN BAWAH PLUS
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.grey.shade400,
                                size: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Pembayaran",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "Rp ${formatRupiah(totalHarga)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: !hasSelectedItems
                    ? null
                    : () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Memproses pesanan...")),
                        );

                        List<Map<String, dynamic>> itemsToCheckout = cartItems
                            .where((i) => i['selected'] == true)
                            .toList();

                        bool sukses = await ApiService.checkout(
                          itemsToCheckout,
                          "midtrans",
                        );

                        if (sukses) {
                          setState(() {
                            // 🚨 LOGIKA BARU: Hapus HANYA item yang berhasil di-checkout
                            cartItems.removeWhere((i) => i['selected'] == true);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Checkout Berhasil!",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal Checkout. Cek Console."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

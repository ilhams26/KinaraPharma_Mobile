import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = true;
  List<dynamic> _activeOrders = [];
  List<dynamic> _historyOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    const String apiUrl =
        ' https://deon-experimental-dalton.ngrok-free.dev/api/orders';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tokenLogin = prefs.getString('token'); 

      if (tokenLogin == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenLogin',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> allOrders = data['data'];

        setState(() {
          _activeOrders = allOrders
              .where(
                (order) =>
                    order['status'] == 'diproses' ||
                    order['status'] == 'siap_diambil',
              )
              .toList();

          _historyOrders = allOrders
              .where(
                (order) =>
                    order['status'] == 'selesai' ||
                    order['status'] == 'dibatalkan',
              )
              .toList();

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memuat pesanan.')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kesalahan jaringan: $e')));
    }
  }

  String _formatRupiah(dynamic price) {
    int value = double.tryParse(price.toString())?.toInt() ?? 0;
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  // Menggabungkan nama obat menjadi satu teks yang rapi
  String _buildItemsText(List<dynamic> items) {
    if (items.isEmpty) return "Tidak ada detail obat";
    List<String> names = items.map((i) {
      final obat = i['obat'] ?? {};
      return "${i['qty']}x ${obat['nama'] ?? 'Obat'}";
    }).toList();
    return names.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pesanan Saya",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Sedang Diproses"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            : TabBarView(
                children: [
                  _buildOrderList(_activeOrders, isHistory: false),
                  _buildOrderList(_historyOrders, isHistory: true),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, {required bool isHistory}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (orders.isEmpty) {
      return Center(
        child: Text(
          isHistory ? "Belum ada riwayat pesanan." : "Tidak ada pesanan aktif.",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final itemsText = _buildItemsText(order['order_items'] ?? []);

          return Card(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['order_code'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isHistory
                              ? (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200)
                              : colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (order['status'] ?? '').toString().toUpperCase(),
                          style: TextStyle(
                            color: isHistory
                                ? (isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700)
                                : colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    itemsText,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Belanja",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Rp ${_formatRupiah(order['total_harga'])}",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (order['payment_status'] == 'unpaid' &&
                      order['metode_pembayaran'] == 'midtrans') ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Menunggu Pembayaran",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

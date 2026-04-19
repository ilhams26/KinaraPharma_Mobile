import 'package:flutter/material.dart';
import 'upload_resep_screen.dart';

class ObatDetailScreen extends StatelessWidget {
  final dynamic obat;

  const ObatDetailScreen({super.key, required this.obat});

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

    // 🚨 LOGIKA BARU YANG SUPER SIMPEL (Sesuai dengan kolom 'jenis' di database)
    bool isObatKeras = obat['jenis'] == 'keras';

    String namaObat = obat['nama'] ?? "Obat";
    String idObat = obat['id'].toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Obat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
              child: const Icon(
                Icons.medication_liquid,
                size: 100,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TAMPILKAN LOGO 'K' HANYA JIKA OBAT KERAS
                  if (isObatKeras)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "K",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  Text(
                    namaObat,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Rp ${formatRupiah(obat['harga'])}",
                    style: TextStyle(
                      fontSize: 22,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deskripsi Obat:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    obat['deskripsi'] ?? "Tidak ada deskripsi obat.",
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  if (isObatKeras) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Peringatan:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Ini adalah obat keras. Anda wajib melampirkan resep dokter asli untuk membeli obat ini.",
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: isObatKeras
                ? ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadResepScreen(
                            obatId: idObat,
                            namaObat: namaObat,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.document_scanner),
                    label: const Text(
                      "Upload Resep untuk Beli",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$namaObat masuk keranjang!")),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text(
                      "Tambah ke Keranjang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

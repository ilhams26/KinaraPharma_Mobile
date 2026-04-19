import 'package:flutter/material.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_kinara.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Halo, Ilham!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Mau cari obat apa hari ini?",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari Paracetamol, Vitamin C...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.secondary,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Banner Upload Resep
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Tetap hijau konstan
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Punya Resep Dokter?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Upload resepmu di sini, biar apoteker kami yang siapkan.",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text(
                            "Upload Resep",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.document_scanner,
                    size: 70,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // KATEGORI OBAT
            const Text(
              "Kategori",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip("Semua", true, colorScheme, isDark),
                  _buildCategoryChip("Obat Bebas", false, colorScheme, isDark),
                  _buildCategoryChip(
                    "Vitamin & Suplemen",
                    false,
                    colorScheme,
                    isDark,
                  ),
                  _buildCategoryChip("Ibu & Anak", false, colorScheme, isDark),
                  _buildCategoryChip("Herbal", false, colorScheme, isDark),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Katalog Obat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Katalog Obat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Lihat Semua",
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    // 🚨 PERBAIKAN: Background Card Obat menyesuaikan tema
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.secondary,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withOpacity(
                          isDark ? 0.05 : 0.2,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Obat Dummy
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            // 🚨 PERBAIKAN: Background Placeholder menyesuaikan tema
                            color: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.grey.shade100,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.medication_liquid,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Info Obat
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Panadol Extra 500mg",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp 12.500",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  "Tambah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget Category Chip
  Widget _buildCategoryChip(
    String title,
    bool isSelected,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool value) {},
        // 🚨 PERBAIKAN: Background Chip Kategori menyesuaikan tema
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        selectedColor: colorScheme.primary,
        checkmarkColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

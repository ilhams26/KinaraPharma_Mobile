import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';
import 'obat_detail_screen.dart';
import '../services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> medicines = [];
  bool isLoading = true;

  // Variabel untuk Search dan Kategori
  String? currentSearch;
  int? currentKategoriId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi Fetch yang sekarang mendukung filter
  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final data = await ApiService.getMedicines(
      search: currentSearch,
      kategoriId: currentKategoriId,
    );
    setState(() {
      medicines = data;
      isLoading = false;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo_kinara.png', height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Halo, Ilham!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // SEARCH BAR FUNGSIONAL
              TextField(
                onChanged: (value) {
                  currentSearch = value;
                  _fetchData(); // Langsung filter saat ngetik
                },
                decoration: InputDecoration(
                  hintText: 'Cari obat...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 25),

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
                    _buildCategoryChip("Semua", null, colorScheme, isDark),
                    _buildCategoryChip("Obat Bebas", 1, colorScheme, isDark),
                    _buildCategoryChip("Obat Keras", 2, colorScheme, isDark),
                    _buildCategoryChip("Vitamin", 3, colorScheme, isDark),
                    _buildCategoryChip("Alat Kesehatan", 4, colorScheme, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Katalog Obat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : medicines.isEmpty
                  ? const Center(child: Text("Obat tidak ditemukan"))
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: medicines.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                      itemBuilder: (context, index) {
                        final obat = medicines[index];
                        final imageUrl =
                            'https://deon-experimental-dalton.ngrok-free.dev/storage/${obat['foto']}';

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ObatDetailScreen(obat: obat),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.secondary),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.medication,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obat['nama'] ?? "Tanpa Nama",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Rp ${formatRupiah(obat['harga'])}",
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await CartService.addToCart(obat);

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "${obat['nama']} berhasil ditambah ke keranjang!",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text("Tambah"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String title,
    int? kategoriId,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    bool isSelected = currentKategoriId == kategoriId;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        ),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            currentKategoriId = kategoriId;
            _fetchData();
          });
        },
        selectedColor: colorScheme.primary,
      ),
    );
  }
}

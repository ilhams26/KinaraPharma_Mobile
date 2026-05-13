import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../main.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    final data = await ApiService.getProfile();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return "";
    if (phone.startsWith('0')) return phone.substring(1);
    return phone;
  }

  void _showEditProfileSheet() {
    String namaAsli = userData?['username'] ?? '';
    String tglLahirAsli = userData?['tanggal_lahir'] ?? '';
    String? genderAsli = userData?['jenis_kelamin'];

    if (tglLahirAsli.contains('T')) {
      tglLahirAsli = tglLahirAsli.split('T')[0];
    }

    String? selectedGender;
    if (genderAsli != null) {
      genderAsli = genderAsli.trim().toUpperCase();
      if (genderAsli == 'L' || genderAsli == 'P') {
        selectedGender = genderAsli;
      }
    }

    TextEditingController nameController = TextEditingController(
      text: namaAsli,
    );
    TextEditingController dobController = TextEditingController(
      text: tglLahirAsli,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final colorScheme = Theme.of(context).colorScheme;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Edit Profil",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Input Nama
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  //  Tanggal Lahir
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      DateTime initialPickerDate = DateTime(2006, 1, 26);
                      if (dobController.text.isNotEmpty) {
                        try {
                          initialPickerDate = DateTime.parse(
                            dobController.text,
                          );
                        } catch (e) {}
                      }

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initialPickerDate,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setModalState(() {
                          dobController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),

                  // Jenis Kelamin
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.wc),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
                      DropdownMenuItem(value: 'P', child: Text("Perempuan")),
                    ],
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedGender = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Menyimpan perubahan...'),
                          ),
                        );

                        bool sukses = await ApiService.updateProfile(
                          nameController.text,
                          dobController.text,
                          selectedGender ?? '',
                        );

                        if (sukses) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadProfile(); // Tarik data fresh dari API
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal memperbarui profil'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Image.asset('assets/images/logo_kinara.png', height: 30),
            const SizedBox(width: 10),
            const Text(
              "Kinara Pharma",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aplikasi Apotek Digital berbasis Mobile untuk memudahkan transaksi kesehatan Anda.",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Text(
              "Dikembangkan Oleh:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("1. M. Ilham Ghazali Simarmata"),
            const Text("2. Tsaabita Parisya Mauladi Aziz"),
            const Text("3. Ai Siti Nur Paojiah"),
            const SizedBox(height: 15),
            const Text(
              "Mitra Resmi:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Apotek Kinara Pharma"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : colorScheme.surface,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.secondary.withOpacity(
                            0.2,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          userData?['username'] ?? "User",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "+62 ${formatPhone(userData?['no_hp'])}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : colorScheme.surface,
                    child: Column(
                      children: [
                        // 🚨 TOMBOL EDIT PROFIL SEKARANG BERFUNGSI
                        ListTile(
                          leading: Icon(
                            Icons.edit_outlined,
                            color: colorScheme.primary,
                          ),
                          title: const Text("Edit Profil"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: _showEditProfileSheet, // PANGGIL MODAL DI SINI
                        ),
                        const Divider(height: 1),

                        ListTile(
                          leading: Icon(
                            Icons.dark_mode_outlined,
                            color: colorScheme.primary,
                          ),
                          title: const Text("Mode Gelap"),
                          trailing: Switch(
                            activeColor: colorScheme.primary,
                            value: themeNotifier.value == ThemeMode.dark,
                            onChanged: (val) => themeNotifier.value = val
                                ? ThemeMode.dark
                                : ThemeMode.light,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                          ),
                          title: const Text("Tentang Aplikasi"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: _showAboutDialog,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            "Keluar Akun",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.remove('token');
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (r) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

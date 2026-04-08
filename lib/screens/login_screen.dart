import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks dari input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true; // State untuk ikon mata
  bool _isLoading = false; // State untuk efek loading tombol

  // ⚠️ PENTING: ALAMAT API (URL)
  // Jika kamu run/testing aplikasi ini sebagai "Windows Desktop", gunakan: 127.0.0.1
  // Jika kamu run/testing menggunakan "Emulator Android", wajib ganti jadi: 10.0.2.2
  final String apiUrl = "http://127.0.0.1:8000/api/login";

  // Fungsi untuk memanggil API Laravel
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Munculkan loading berputar
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        // Jika API membalas sukses (Status 200)
        final data = json.decode(response.body);

        // Simpan Token JWT ke dalam brankas HP (SharedPreferences)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'token',
          data['token'],
        ); // Pastikan 'token' sesuai respon API kamu

        // Tampilkan pesan sukses di bawah layar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login Berhasil! Token tersimpan.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Navigasi ke Halaman Beranda (Kita buat di langkah selanjutnya)
      } else {
        // Jika salah password/username (Status 401 dll)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login Gagal: Periksa kembali data Anda.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Jika server Laravel mati / salah IP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error Server: Gagal terhubung ke API.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Matikan loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F7FF), // Background biru muda mirip web
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Container(
            padding: EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF1976D2),
                width: 2,
              ), // Garis pinggir biru utama
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Apotek Sementara (Nanti bisa diganti gambar logo asli)
                Icon(Icons.local_pharmacy, size: 80, color: Color(0xFF4CAF50)),
                SizedBox(height: 10),
                Text(
                  "Masuk Ke Akun Anda",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 25),

                // Input Username
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Color(0xFFF0F7FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFF1976D2)),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Input Password dengan Ikon Mata (Obscure Text)
                TextField(
                  controller: _passwordController,
                  obscureText:
                      _obscurePassword, // Ini yang bikin jadi bintang-bintang
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Color(0xFFF0F7FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFF1976D2)),
                    ),
                    // Ikon Mata di sebelah kanan
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Ubah state mata tertutup/terbuka saat diklik
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(
                        0xFF1976D2,
                      ), // Warna tombol biru utama
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : _login, // Matikan klik saat loading
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class UploadResepScreen extends StatefulWidget {
  const UploadResepScreen({super.key});

  @override
  State<UploadResepScreen> createState() => _UploadResepScreenState();
}

class _UploadResepScreenState extends State<UploadResepScreen> {
  File? _image;
  final _picker = ImagePicker();
  bool _isUploading = false;

  // Fungsi mengambil gambar
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi kirim ke API
  Future<void> _handleUpload() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    bool sukses = await ApiService.uploadPrescription(_image!.path);

    setState(() => _isUploading = false);

    if (sukses) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Resep berhasil dikirim! Mohon tunggu validasi apoteker.",
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengirim resep. Cek koneksi atau server."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Resep Dokter",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Punya resep dari dokter?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Foto resep asli Anda, agar apoteker kami dapat memprosesnya.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // AREA PREVIEW GAMBAR
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: _image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 80,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Belum ada foto terpilih",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),

            // TOMBOL PILIH FOTO
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Kamera"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galeri"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // TOMBOL SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_image == null || _isUploading)
                    ? null
                    : _handleUpload,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Kirim Resep Sekarang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    final data = await ApiService.getNotifications();
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> _markAsRead(String id, bool isRead) async {
    if (isRead) return; // Kalau udah dibaca, gak usah nembak API lagi
    bool sukses = await ApiService.markNotificationAsRead(id);
    if (sukses) {
      _fetchNotifications(); // Refresh list biar background putih/titik merah hilang
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Belum ada notifikasi",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  bool isRead =
                      notif['is_read'] == 1 || notif['is_read'] == true;

                  return Card(
                    elevation: isRead ? 0 : 2,
                    color: isRead
                        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        : (isDark
                              ? const Color(0xFF2C3E2C)
                              : colorScheme.primary.withOpacity(0.05)),
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isRead
                            ? Colors.transparent
                            : colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isRead
                            ? Colors.grey.shade300
                            : colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.notifications,
                          color: isRead ? Colors.grey : colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        notif['title'] ?? "Pemberitahuan",
                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          notif['message'] ?? "",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.black54,
                          ),
                        ),
                      ),
                      onTap: () async {
                        // 1. TANDAI DIBACA
                        await _markAsRead(notif['id'].toString(), isRead);

                        String title = (notif['title'] ?? "")
                            .toString()
                            .toLowerCase();
                        String message = (notif['message'] ?? "").toString();

                        // 2. CEK JIKA INI NOTIFIKASI RESEP DISETUJUI
                        if (title.contains("disetujui") ||
                            title.contains("valid") ||
                            title.contains("acc")) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          bool isUsed =
                              prefs.getBool('resep_used_${notif['id']}') ??
                              false;

                          if (isUsed) {
                            // Jika sudah pernah diklik sebelumnya
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Resep ini sudah pernah dimasukkan ke keranjang!",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            // Tampilkan Loading
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            //  CARI OBAT BERDASARKAN PESAN
                            final allMedicines =
                                await ApiService.getMedicines();
                            dynamic obatTarget;

                            for (var obat in allMedicines) {
                              if (message.toLowerCase().contains(
                                obat['nama'].toString().toLowerCase(),
                              )) {
                                obatTarget = obat;
                                break;
                              }
                            }

                            if (context.mounted)
                              Navigator.pop(context); // Tutup Loading

                            if (obatTarget != null) {
                              // 4. MASUKKAN KERANJANG & KUNCI
                              await CartService.addToCart(obatTarget);
                              await prefs.setBool(
                                'resep_used_${notif['id']}',
                                true,
                              ); // KUNCI!

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${obatTarget['nama']} berhasil dimasukkan ke keranjang!",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              // Jika nama obat tidak disebut di notif
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Resep Disetujui"),
                                    content: const Text(
                                      "Resep Anda valid. Silakan cari obat tersebut di beranda dan tambahkan ke keranjang secara manual.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Tutup"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          }
                        } else {
                          // JIKA NOTIFIKASI BIASA
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(notif['title'] ?? "Pemberitahuan"),
                                content: Text(notif['message'] ?? ""),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Tutup"),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

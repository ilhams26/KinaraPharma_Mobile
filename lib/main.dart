import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Sesuaikan lokasi filemu

// 🚨 1. Variabel Global pengontrol Tema
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚨 2. Bungkus dengan ValueListenableBuilder agar aplikasi bereaksi saat sakelar ditekan
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Kinara Pharma',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // Mengikuti nilai dari profil
          // --- TEMA TERANG (Sesuai kesepakatan sebelumnya) ---
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF4CAF50),
              primary: const Color(0xFF4CAF50),
              secondary: const Color(0xFF8BC34A),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF9F9F9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF4CAF50),
              elevation: 0,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            useMaterial3: true,
          ),

          // --- TEMA GELAP (Elegan dan tidak bikin sakit mata) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF4CAF50),
              primary: const Color(
                0xFF8BC34A,
              ), 
              secondary: const Color(0xFF4CAF50),
              surface: const Color(
                0xFF1E1E1E,
              ), // Latar Card abu-abu sangat gelap
            ),
            scaffoldBackgroundColor: const Color(
              0xFF121212,
            ), // Latar utama hitam murni
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Color(0xFF8BC34A),
              elevation: 0,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF8BC34A,
                ), // Button lime di mode gelap
                foregroundColor:
                    Colors.black, // Teks hitam di atas button terang
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            useMaterial3: true,
          ),

          home: const LoginScreen(),
        );
      },
    );
  }
}

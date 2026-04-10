import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apotek Kinara Mobile',
      debugShowCheckedModeBanner: false,

      //(LIGHT MODE
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8BC34A), // Light Green Base
          primary: const Color(0xFFB0CF0B), // Lime Green (Untuk aksen cerah)
          secondary: const Color(0xFF2E7D32), // Hijau Agak Tua (Untuk Button)
          surface: const Color(0xFFF9F9F9), // Latar belakang sangat cerah/putih
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),

        // Aturan Global untuk semua Tombol (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32), // Button hijau agak tua
            foregroundColor: Colors.white, // Teks button putih
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),

        // Aturan Global untuk AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, 
          foregroundColor: Color(0xFF2E7D32), // Icon/Teks di AppBar hijau tua
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),

      // DARK MODE
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF66BB6A),
          secondary: Color(0xFFB0CF0B),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSurface: Color(0xFFF5F5EC),
          outline: Color(0xFF0F5E3C),
        ),
        useMaterial3: true,
      ),

      themeMode: ThemeMode.system,

      home: const LoginScreen(),
    );
  }
}

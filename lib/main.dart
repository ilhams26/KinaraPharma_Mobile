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

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Hijau Biasa (Utama)
          primary: const Color(0xFF4CAF50), // Hijau Biasa
          secondary: const Color(
            0xFF8BC34A,
          ), // Light Green / Lime (Aksen & Border)
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(
          0xFFF9F9F9,
        ), // Latar belakang abu-abu sangat pudar

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Button Hijau Biasa
            foregroundColor: Colors.white, // Teks DI JAMIN putih
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF4CAF50), 
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

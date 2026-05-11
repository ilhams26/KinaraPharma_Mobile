import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Sesuaikan lokasi file login kamu

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Kinara Pharma',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, 
          //TEMA TERANG 
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF4CAF50),
              primary: const Color(0xFF4CAF50), // Hijau biasa
              secondary: const Color(0xFF8BC34A), // Lime green
              surface: Colors.white,
              surfaceContainerHighest: Colors.grey.shade100,
            ),
            scaffoldBackgroundColor: const Color(0xFFF9F9F9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF4CAF50),
              elevation: 0,
              centerTitle: true,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF4CAF50),
              unselectedItemColor: Colors.grey,
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

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF4CAF50),
              primary: const Color(0xFF8BC34A), 
              secondary: const Color(0xFF4CAF50),
              surface: const Color(
                0xFF1E1E1E,
              ), 
              surfaceContainerHighest: const Color(
                0xFF2C2C2C,
              ), 
            ),
            scaffoldBackgroundColor: const Color(
              0xFF121212,
            ), 
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Color(0xFF8BC34A),
              elevation: 0,
              centerTitle: true,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFF8BC34A),
              unselectedItemColor: Colors.grey,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                foregroundColor: Colors.black, 
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

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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5EC), 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F5E3C),      
          secondary: Color(0xFFB0CF0B),   
          surface: Colors.white,           
          onPrimary: Colors.white,        
          onSurface: Color(0xFF333333),   
          outline: Color(0xFF66BB6A),     
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
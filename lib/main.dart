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
      debugShowCheckedModeBanner:
          false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1976D2)),
        useMaterial3: true,
      ),
      home: LoginScreen(), 
    );
  }
}

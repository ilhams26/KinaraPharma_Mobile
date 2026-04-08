import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

// Halaman Login Pembeli (Mobile)
enum LoginState { inputPhone, inputOtp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  LoginState _currentState = LoginState.inputPhone;
  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10)
      return _showError("Nomor HP tidak valid.");

    setState(() => _isLoading = true);

    try {
      bool success = await ApiService.requestOtp(phone);
      if (success) {
        setState(() => _currentState = LoginState.inputOtp);
        _showSuccess("OTP dikirim (Gunakan: 1234)");
      } else {
        _showError("Gagal mengirim OTP.");
      }
    } catch (e) {
      _showError("Error: Pastikan server Laravel menyala.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.trim().length != 4)
      return _showError("Masukkan 4 digit OTP.");

    setState(() => _isLoading = true);

    try {
      String? token = await ApiService.verifyOtp(
        _phoneController.text.trim(),
        _otpController.text.trim(),
      );
      if (token != null) {
        _showSuccess("Login Berhasil!");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        _showError("Kode OTP Salah.");
      }
    } catch (e) {
      _showError("Error: Gagal terhubung ke API.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_kinara.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Masuk Ke Akun Anda",
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                TextField(
                  controller: _phoneController,
                  enabled: _currentState == LoginState.inputPhone,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    prefixText: '+62 ',
                    filled: true,
                    fillColor: isDark
                        ? Colors.black26
                        : const Color(0xFFF5F5EC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_android,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                if (_currentState == LoginState.inputOtp) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      letterSpacing: 10,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Masukkan OTP',
                      counterText: "",
                      filled: true,
                      fillColor: isDark
                          ? Colors.black26
                          : const Color(0xFFF5F5EC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                              _currentState = LoginState.inputPhone;
                              _otpController.clear();
                            }),
                      child: Text(
                        "Salah Nomor? Kembali",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentState == LoginState.inputPhone
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      foregroundColor: _currentState == LoginState.inputPhone
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : (_currentState == LoginState.inputPhone
                              ? _handleSendOtp
                              : _handleVerifyOtp),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _currentState == LoginState.inputPhone
                                ? "Kirim Kode OTP"
                                : "Verifikasi & Masuk",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Baru?",
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {},
                          child: Text(
                            "Daftar Sekarang",
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Lupa Nomor HP?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

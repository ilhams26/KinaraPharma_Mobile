import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    
    if (phone.isEmpty || phone.length < 10) {
      _showErrorSnackBar("Nomor HP tidak valid. Masukkan minimal 10 digit.");
      return;
    }

    setState(() { _isLoading = true; });

    try {
      bool success = await ApiService.requestOtp(phone);
      if (success) {

        setState(() {
          _currentState = LoginState.inputOtp;
        });
        _showSuccessSnackBar("Kode OTP (Dummy: 1234) berhasil dikirim ke nomor Anda.");
      } else {
        _showErrorSnackBar("Gagal mengirim OTP. Nomor tidak terdaftar atau error server.");
      }
    } catch (e) {
      _showErrorSnackBar("Terjadi kesalahan koneksi.");
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  // Fungsi 2: Handle Tombol "Verifikasi OTP"
  Future<void> _handleVerifyOtp() async {
    String phone = _phoneController.text.trim();
    String otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 4) { 
      _showErrorSnackBar("Masukkan 4 digit kode OTP yang benar.");
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String? token = await ApiService.verifyOtp(phone, otp);
      if (token != null) {
        _showSuccessSnackBar("Verifikasi Berhasil! Selamat Datang.");

      } else {
        _showErrorSnackBar("Kode OTP salah atau sudah kadaluarsa.");
      }
    } catch (e) {
      _showErrorSnackBar("Terjadi kesalahan koneksi.");
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  void _showErrorSnackBar(String message) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Palet warna dinamis
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Image.asset(
                  'assets/images/logo_kinara.png',
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jika asset logo belum disetup
                    return Icon(Icons.error_outline, size: 60, color: colorScheme.primary);
                  },
                ),
                
                const SizedBox(height: 10),
                Text(
                  "Masuk Ke Akun Anda",

                  style: TextStyle(color: const Color(0xFFBDBDBD), fontSize: 14, fontWeight: FontWeight.bold), 
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
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    filled: true,
                    fillColor: isDarkMode ? Colors.black26 : const Color(0xFFF0F7FF), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                    prefixIcon: Icon(Icons.phone_android, color: const Color(0xFFBDBDBD)),
                  ),
                ),
                const SizedBox(height: 15),

                if (_currentState == LoginState.inputOtp)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number, 
                  maxLength: 4, 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface, letterSpacing: 10, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Masukkan 4 Digit Kode OTP',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), letterSpacing: 0, fontSize: 12),
                    counterText: "",
                    filled: true,
                    fillColor: isDarkMode ? Colors.black26 : const Color(0xFFF0F7FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: colorScheme.secondary, width: 2)), // Pake Lime Green untuk focused OTP
                  ),
                ),
                
                if (_currentState == LoginState.inputOtp) const SizedBox(height: 10),

                if (_currentState == LoginState.inputOtp)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      setState(() { _currentState = LoginState.inputPhone; _otpController.clear(); });
                    },
                    child: Text("Salah Nomor? Kembali", style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentState == LoginState.inputPhone ? colorScheme.primary : colorScheme.secondary, // Warna berubah sesuai state (Pine vs Lime)
                      foregroundColor: _currentState == LoginState.inputPhone ? colorScheme.onPrimary : colorScheme.primary, // Teks hitam di Lime, putih di Pine
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _isLoading ? null : (_currentState == LoginState.inputPhone ? _handleSendOtp : _handleVerifyOtp), 
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) // Menyesuaikan warna indicator otomatis
                        : Text(
                            _currentState == LoginState.inputPhone ? "Kirim Kode OTP" : "Verifikasi & Masuk", 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("Baru?", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 5), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          onPressed: () { /* TODO: Navigasi ke Daftar */ },
                          child: Text("Daftar Sekarang", style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13)), // Pake Lime Green sesuai logo
                        ),
                      ],
                    ),

                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: () { /* TODO: Navigasi Lupa Nomor */ },
                      child: Text("Lupa Nomor HP?", style: TextStyle(color: Colors.grey[500], fontSize: 12, decoration: TextDecoration.underline)),
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
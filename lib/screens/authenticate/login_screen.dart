import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart'; // Renkler
import '../../services/auth_service.dart'; // Servis
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _error = '';

  void _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = "Lütfen tüm alanları doldurun.");
      return;
    }

    setState(() { _isLoading = true; _error = ''; });

    dynamic result = await _auth.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim()
    );

    if (result == null) {
      setState(() {
        _isLoading = false;
        _error = 'Giriş başarısız. E-posta veya şifre hatalı.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    height: 150,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text("Hoş Geldin!", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.scuRed)),
                const SizedBox(height: 10),
                const Text("Kampüs rehberine giriş yap.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.scuRed.withOpacity(0.7)),
                    hintText: "E-posta",
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.scuRed.withOpacity(0.7)),
                    hintText: "Şifre",
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                if (_error.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.scuRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Giriş Yap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın yok mu?", style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text("Kayıt Ol", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.scuRed)),
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
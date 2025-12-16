import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // 1. YENİ KONTROLCÜ

  bool _isLoading = false;
  String _error = '';

  void _register() async {
    // 2. BOŞ ALAN KONTROLÜ (Şifre Tekrarı da eklendi)
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _error = "Lütfen tüm alanları doldurun.");
      return;
    }

    // 3. ŞİFRE EŞLEŞME KONTROLÜ (KRİTİK KISIM)
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = "Girdiğin şifreler eşleşmiyor.");
      return;
    }

    setState(() { _isLoading = true; _error = ''; });

    dynamic result = await _auth.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim()
    );

    if (result == null) {
      setState(() {
        _isLoading = false;
        _error = 'Kayıt başarısız. Lütfen tekrar deneyin.';
      });
    } else {
      if (mounted) Navigator.pop(context);
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
                  tag: 'app_logo_register',
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    // Logon yoksa Icon kullanır, varsa Image.asset kullanabilirsin
                    child: Image.asset('assets/images/logo.png', height: 100, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Aramıza Katıl", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.scuRed)),
                const SizedBox(height: 10),
                const Text("Kampüsün tadını çıkarmaya başla!", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 40),

                // AD SOYAD
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.scuRed),
                    hintText: "Ad Soyad",
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),

                // E-POSTA
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.scuRed),
                    hintText: "E-posta",
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),

                // ŞİFRE
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.scuRed),
                    hintText: "Şifre",
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),

                // 4. YENİ ŞİFRE TEKRAR ALANI
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_reset, color: AppColors.scuRed), // Farklı ikon
                    hintText: "Şifreyi Tekrar Gir",
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                if (_error.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.scuRed,
                    foregroundColor: Colors.white,
                    padding:  EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Kayıt Ol", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Zaten hesabın var mı?", style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Giriş Yap", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.scuRed)),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

// ✅ GÜNCELLENMİŞ IMPORTLAR:
import 'authenticate/login_screen.dart'; // Login Ekranı
import 'home/home_screen.dart';    // Ana İskelet (Artık 'home' klasörü altında)

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'dan gelen kullanıcı bilgisini dinle
    final user = Provider.of<AppUser?>(context);

    // Kullanıcı durumu kontrolü
    if (user == null) {
      // Kullanıcı YOK -> Login Ekranına git
      return const LoginScreen();
    } else {
      // Kullanıcı VAR -> Ana İskelete (Home + Map + Profil) git
      return const HomeScreen();
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../map_screen.dart'; // Senin Haritan
import 'tabs/home_tab.dart'; // Ana Sayfa Akışı (B Takımı)
import 'tabs/profile_tab.dart'; // Profil (B Takımı)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sayfalar Listesi
  final List<Widget> _pages = [
    const HomeTab(),   // 0: Ana Sayfa (Listeler)
    const MapScreen(), // 1: Harita (Senin Yaptığın)
    const ProfileTab(),// 2: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Seçili sayfayı göster

      bottomNavigationBar: Container(
        // Menüye dış kaplama yapıyoruz
        decoration: BoxDecoration(
          color: Colors.white,
          // Üst köşeleri yuvarlatıyoruz (Daha modern duruş)
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          // Yukarı doğru hafif gölge (Harita/Liste ile karışmasın diye)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Siyahın %10'u kadar gölge
              blurRadius: 20, // Gölgeyi yay
              offset: const Offset(0, -5), // Gölgeyi yukarı ittir
            ),
          ],
        ),

        // Yuvarlattığımız köşelerden taşan kısımları kesiyoruz
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: NavigationBar(
            height: 75, // Yükseklik ideal (70-80 arası iyidir)
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),

            // Renk Ayarları
            backgroundColor: Colors.white, // Arka plan bembeyaz
            surfaceTintColor: Colors.transparent, // M3'ün otomatik gri tonunu kapat
            indicatorColor: AppColors.scuRed.withOpacity(0.1), // Seçili olanın arkasındaki hap rengi (Çok açık kırmızı)

            // Animasyon süresi (Daha akıcı geçiş)
            animationDuration: const Duration(milliseconds: 600),

            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined), // Seçili DEĞİLKEN (İçi boş)
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.scuRed), // Seçiliyken (Dolu ve Kırmızı)
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded, color: AppColors.scuRed),
                label: 'Harita',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.scuRed),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
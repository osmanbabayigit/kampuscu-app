import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/user_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? _localAvatarUrl;
  String? _localName;

  //DiceBear
  final List<String> _avatarOptions = const [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Bob',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Willow',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Jack',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Mimi',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Leo',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Zoe',
  ];

  // --- İSİM DÜZENLEME PENCERESİ ---
  void _showNameEditDialog(BuildContext context, User? firebaseUser, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("İsmi Düzenle", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: nameController,
                  autofocus: true,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Ad Soyad",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    prefixIcon: Icon(Icons.person, color: AppColors.scuRed.withOpacity(0.8)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text("Vazgeç", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;
                      final newName = nameController.text.trim();
                      Navigator.pop(ctx);

                      setState(() => _localName = newName);
                      _showSuccessSnackBar("İsmin güncellendi! ✨");

                      if (firebaseUser != null) {
                        firebaseUser.updateDisplayName(newName);
                        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({'displayName': newName});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.scuRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Kaydet", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- AVATAR SEÇME PENCERESİ ---
  void _showAvatarSelection(BuildContext context, User? firebaseUser) {
    if (firebaseUser == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 380,
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const Text("Avatar Seç", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 20, mainAxisSpacing: 20,
                  ),
                  itemCount: _avatarOptions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => _localAvatarUrl = null);
                          _showSuccessSnackBar("Profil fotoğrafı kaldırıldı.");
                          firebaseUser.updatePhotoURL(null);
                          FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({'photoUrl': FieldValue.delete()});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                          ),
                          child: Icon(Icons.delete_outline, size: 24, color: Colors.grey[600]),
                        ),
                      );
                    }
                    final url = _avatarOptions[index - 1];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        setState(() => _localAvatarUrl = url);
                        _showSuccessSnackBar("Avatar güncellendi! 🚀");
                        firebaseUser.updatePhotoURL(url);
                        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({'photoUrl': url});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade100, width: 2),
                        ),
                        child: CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage(url)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        backgroundColor: AppColors.scuDarkRed, // Daha koyu bildirim
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser?>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final AuthService _auth = AuthService();

    if (appUser == null) return const Center(child: Text("Oturum Açın."));

    final dbName = appUser.displayName ?? appUser.email.split('@').first;
    final displayName = _localName ?? dbName;
    final String firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";
    final String? currentPhotoUrl = _localAvatarUrl ?? (appUser.photoUrl != null && appUser.photoUrl!.isNotEmpty ? appUser.photoUrl : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Arka plan biraz daha gri, kartlar patlasın
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 80),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Profil",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- 1. AVATAR ALANI (KOYU KIRMIZI TEMA) ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Dış Halka
                  Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.scuRed.withOpacity(0.2), // Gölge biraz daha belirgin
                            blurRadius: 30,
                            offset: const Offset(0, 10)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: CircleAvatar(
                        radius: 64,
                        // BURASI DEĞİŞTİ: Arka plan Şeffaf değil, Koyu Kırmızı Dolu Renk
                        backgroundColor: AppColors.scuRed,
                        backgroundImage: currentPhotoUrl != null ? NetworkImage(currentPhotoUrl) : null,
                        child: currentPhotoUrl == null
                        // Harf rengi Beyaz oldu, kontrast için
                            ? Text(firstLetter, style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white))
                            : null,
                      ),
                    ),
                  ),

                  // Edit Butonu
                  GestureDetector(
                    onTap: () => _showAvatarSelection(context, firebaseUser),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade100, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.edit, color: AppColors.scuDarkRed, size: 20), // İkon rengi koyu kırmızı
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // --- 2. İSİM KARTI ---
            GestureDetector(
              onTap: () => _showNameEditDialog(context, firebaseUser, displayName),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.scuRed.withOpacity(0.1), // Hafif kırmızı zemin
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // İkon koyu kırmızı
                      child: const Icon(Icons.person_rounded, color: AppColors.scuRed, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ad Soyad", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_rounded, size: 18, color: Colors.grey[300]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- 3. E-POSTA KARTI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.email_rounded, color: Colors.grey[700], size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("E-posta", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          appUser.email,
                          style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // --- 4. ÇIKIŞ BUTONU ---
            TextButton(
              onPressed: () async { await _auth.signOut(); },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.scuRed.withOpacity(0.1), // Hafif kırmızı
                foregroundColor: AppColors.scuDarkRed, // Koyu kırmızı yazı
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text("Çıkış Yap", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );

  }
}
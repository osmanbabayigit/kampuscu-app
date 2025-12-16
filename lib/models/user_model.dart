class AppUser {
  final String uid;
  final String email;
  final String? displayName; // Profilde görünecek isim
  final String? photoUrl;    // Profil fotoğrafı

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });


}
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place_model.dart';
import '../core/constants/app_colors.dart';

class CustomVenueCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const CustomVenueCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ZAMAN HESAPLAMASI
    final int currentHour = DateTime.now().hour;
    final bool isOpen = currentHour >= place.openHour && currentHour < place.closeHour;

    // Renkleri tanımlayalım
    final Color statusColor = isOpen ? Colors.greenAccent : Colors.redAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 2. ARKA PLAN RESMİ
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Hero(
                tag: place.id,
                child: place.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(color: AppColors.scuRed, strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholderBg(),
                )
                    : _buildPlaceholderBg(),
              ),
            ),

            // 3. ALT BİLGİ PANELI
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent], // Daha yumuşak geçiş
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mekan İsmi (En Dikkat Çekici Yer)
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900, // Daha kalın font
                          letterSpacing: 0.5
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- BİLGİ SATIRI (MİNİMALİST TASARIM) ---
                    Row(
                      children: [

                        // AÇIK/KAPALI ETİKETİ (SADELEŞTİRİLDİ)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            // Arka plan yok (veya çok hafif siyah), sadece çerçeve
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(20), // Tam oval (Hap şeklinde)
                          ),
                          child: Row(
                            children: [
                              // Durum Noktası (Dot)
                              Icon(Icons.circle, size: 8, color: statusColor),
                              const SizedBox(width: 6),
                              // Durum Yazısı
                              Text(
                                isOpen
                                    ? "AÇIK (${place.closeHour}:00)"
                                    : "KAPALI",
                                style: const TextStyle(
                                  color: Colors.white, // Yazı beyaz kalsın, göz yormaz
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(), // Araya boşluk at

                        // Yıldız ve Puan
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              " (${place.reviewCount})",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBg() {
    IconData iconData = Icons.store;
    if (place.category == 'restaurant') iconData = Icons.restaurant;
    if (place.category == 'cafe') iconData = Icons.local_cafe;
    if (place.category == 'faculty') iconData = Icons.school;

    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey[300],
      child: Center(
        child: Icon(iconData, color: Colors.white, size: 60),
      ),
    );
  }
}
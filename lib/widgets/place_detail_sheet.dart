import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place_model.dart';
import '../core/constants/app_colors.dart';
import '../screens/review_input_sheet.dart';
import 'review_list_widget.dart';
import 'menu_card.dart';

class PlaceDetailSheet extends StatelessWidget {
  final Place place;
  const PlaceDetailSheet({super.key, required this.place});

  // Haritayı açma fonksiyonu
  void _launchMapsUrl(double lat, double lon) async {
    final String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Harita açılamadı';
    }
  }

  // Resim yoksa gösterilecek gri kutu
  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.inputFill,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text("Görsel Yok", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentHour = DateTime.now().hour;
    final bool isOpen = currentHour >= place.openHour && currentHour < place.closeHour;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -10))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(
            children: [
              ListView(
                controller: controller,
                padding: EdgeInsets.zero,
                children: [
                  // 1. KAPAK FOTOĞRAFI
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: place.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: place.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                        : _buildPlaceholder(),
                  ),

                  // 2. İÇERİK ALANI
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mekan Adı
                        Text(
                          place.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),

                        // Durum ve Puan
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: isOpen ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: Text(
                                  isOpen
                                      ? "AÇIK (${place.closeHour}:00'a kadar)"
                                      : "KAPALI (Açılış: ${place.openHour}:00)",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isOpen ? Colors.green.shade800 : Colors.red.shade800
                                  )
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text("${place.rating.toStringAsFixed(1)} (${place.reviewCount})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Butonlar
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchMapsUrl(place.latitude, place.longitude),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.scuRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.near_me_rounded, size: 18),
                                label: const Text("Yol Tarifi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => ReviewInputSheet(placeId: place.id),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.inputFill,
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text("Puan Ver", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 3. MENÜ KISMI
                        if (place.menus.isNotEmpty) ...[
                          const Text("Menü", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: place.menus.length,
                              itemBuilder: (context, index) {
                                final item = place.menus[index];
                                return MenuCard(
                                    name: item.name,
                                    price: item.price.toStringAsFixed(0)
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Yorumlar
                        const Text("Değerlendirmeler", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ReviewListWidget(placeId: place.id)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Kapatma Butonu
              Positioned(
                top: 15, right: 15,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),

              // Tutamaç
              Positioned(
                top: 8, left: 0, right: 0,
                child: Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
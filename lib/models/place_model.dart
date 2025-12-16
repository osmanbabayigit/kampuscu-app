import 'menu_item_model.dart';

class Place {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final int openHour;
  final int closeHour;

  // 🔥 YENİ: Menü Listesi (Array)
  final List<MenuItem> menus;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.openHour,
    required this.closeHour,
    required this.menus, // Zorunlu alan
  });

  factory Place.fromMap(Map<String, dynamic> data, String documentId) {
    return Place(
      id: documentId,
      name: data['name'] ?? '',
      category: data['category'] ?? 'other',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
      reviewCount: (data['reviewCount'] as num? ?? 0).toInt(),
      latitude: (data['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (data['longitude'] as num? ?? 0.0).toDouble(),
      openHour: (data['openHour'] as num? ?? 9).toInt(),
      closeHour: (data['closeHour'] as num? ?? 17).toInt(),

      // Firebase 'menus' Array'ini List<MenuItem>'a çeviriyoruz
      menus: (data['menus'] as List<dynamic>? ?? [])
          .map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
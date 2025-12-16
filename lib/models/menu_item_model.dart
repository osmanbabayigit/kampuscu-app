class MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory MenuItem.fromMap(Map<String, dynamic> data) {
    return MenuItem(
      name: data['name'] ?? 'Ürün Adı Yok',
      description: data['description'] ?? '',
      price: (data['price'] as num? ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
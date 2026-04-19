class Product {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final String weight;
  final double price;
  final double? originalPrice;
  final int stock;
  final bool isBestSeller;
  final bool isDiscounted;
  final List<String> imageUrls;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.weight,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.isBestSeller = false,
    this.isDiscounted = false,
    this.imageUrls = const [],
    this.description = 'Premium quality product sourced directly for Diesel Cash & Carry customers.',
  });

  // Helper for single image URL (compatibility)
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['image_urls'] != null && json['image_urls'] is List) {
      urls = (json['image_urls'] as List).map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      emoji: json['emoji'] ?? '📦',
      weight: json['weight'] ?? '',
      price: (json['sale_price'] ?? json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price'] != null ? (json['original_price'] as num).toDouble() : null,
      stock: json['stock_count'] ?? 0,
      isBestSeller: json['is_best_seller'] ?? false,
      isDiscounted: json['is_discounted'] ?? false,
      imageUrls: urls,
      description: json['description'] ?? 'Premium quality product sourced directly for Diesel Cash & Carry customers.',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'emoji': emoji,
      'weight': weight,
      'sale_price': price,
      'original_price': originalPrice,
      'stock_count': stock,
      'is_best_seller': isBestSeller,
      'is_discounted': isDiscounted,
      'image_urls': imageUrls,
      'description': description,
    };
  }
}

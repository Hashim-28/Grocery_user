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
  final String? imageUrl;
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
    this.imageUrl,
    this.description = 'Premium quality product sourced directly for Diesel Cash & Carry customers.',
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}

class Category {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.imageUrl,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class Order {
  final String id;
  final String date;
  final List<CartItem> items;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final String deliverySpeed;
  int statusIndex; // 0–4

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.deliverySpeed = 'Standard',
    this.statusIndex = 0,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class Deal {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String emoji;
  final int backgroundColor;
  final String? imageUrl;
  final String targetCategory;

  const Deal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.emoji,
    required this.backgroundColor,
    this.imageUrl,
    required this.targetCategory,
  });
}

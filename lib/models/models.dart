class Product {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final double? originalPrice;
  final String weight;
  final String category;
  final int stock;
  final bool isBestSeller;
  final String? imageUrl;
  final String description;
  final bool isDiscounted;
  // State-related fields (optional but kept for compatibility if needed, though AppState should ideally handle this)
  bool isInCart;
  int cartQuantity;

  Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    this.originalPrice,
    required this.weight,
    required this.category,
    required this.stock,
    this.isBestSeller = false,
    this.isDiscounted = false,
    this.imageUrl,
    this.description = 'Premium quality product sourced directly for Desil Cash & Carry customers. Hand-picked for freshness and quality assurance.',
    this.isInCart = false,
    this.cartQuantity = 0,
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
  int statusIndex; // 0: Received, 1: Preparing, 2: Out for Delivery, 3: Delivered

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.statusIndex = 0,
  });
}

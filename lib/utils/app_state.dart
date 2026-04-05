import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // ─── Cart ─────────────────────────────────────────────────────────────────
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalCartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);

  double get freeDeliveryThreshold => 5000.0;

  double get deliveryFee => cartSubtotal >= freeDeliveryThreshold ? 0 : 80;

  double get cartTotal => cartSubtotal + deliveryFee;

  double get remainingForFreeDelivery {
    final remaining = freeDeliveryThreshold - cartSubtotal;
    return remaining > 0 ? remaining : 0;
  }

  int getCartQuantity(String productId) {
    final idx = _cartItems.indexWhere((e) => e.product.id == productId);
    return idx >= 0 ? _cartItems[idx].quantity : 0;
  }

  void addToCart(Product product) {
    final idx = _cartItems.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      _cartItems[idx].quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final idx = _cartItems.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;
    if (_cartItems[idx].quantity <= 1) {
      _cartItems.removeAt(idx);
    } else {
      _cartItems[idx].quantity--;
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ─── Orders ───────────────────────────────────────────────────────────────
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void placeOrder({
    required String address,
    required String paymentMethod,
    required String deliverySpeed,
  }) {
    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: _formattedDate(),
      items: List.from(_cartItems),
      total: cartTotal,
      deliveryAddress: address,
      paymentMethod: paymentMethod,
      deliverySpeed: deliverySpeed,
    );
    _orders.insert(0, order);
    clearCart();
  }

  void updateOrderStatus(String orderId, int newStatus) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].statusIndex = newStatus;
      notifyListeners();
    }
  }

  // ─── Profile ──────────────────────────────────────────────────────────────
  String _deliveryAddress = 'House 12, Block A, Gulberg III, Lahore';
  String get deliveryAddress => _deliveryAddress;

  void updateDeliveryAddress(String addr) {
    _deliveryAddress = addr;
    notifyListeners();
  }

  String? _profileImagePath;
  String? get profileImagePath => _profileImagePath;

  void updateProfileImage(String path) {
    _profileImagePath = path;
    notifyListeners();
  }

  // ─── Theme ────────────────────────────────────────────────────────────────
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

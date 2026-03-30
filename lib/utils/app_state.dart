import 'package:flutter/material.dart';
import '../models/models.dart';

/// Simple in-memory cart & state manager (no external state library needed)
class AppState extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final List<Order> _orders = [];
  String _deliveryAddress = 'Gulberg III, Lahore';
  String? _profileImagePath;

  List<CartItem> get cartItems => _cartItems;
  List<Order> get orders => _orders;
  String get deliveryAddress => _deliveryAddress;
  String? get profileImagePath => _profileImagePath;

  int get totalCartCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.total);

  double get totalCartPrice => cartTotal;

  void addToCart(Product product) {
    final existing = _cartItems.where((i) => i.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final item = _cartItems.where((i) => i.product.id == productId).firstOrNull;
    if (item != null) {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void placeOrder({
    required String paymentMethod,
    required String deliveryType,
  }) {
    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      items: List.from(_cartItems),
      total: cartTotal,
      deliveryAddress: _deliveryAddress,
      paymentMethod: paymentMethod,
      statusIndex: 0,
    );
    _orders.insert(0, order);
    clearCart();
    notifyListeners();
  }

  void updateOrderStatus(String orderId, int newStatus) {
    final order = _orders.where((o) => o.id == orderId).firstOrNull;
    if (order != null) {
      order.statusIndex = newStatus;
      notifyListeners();
    }
  }

  void updateDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void updateProfileImage(String path) {
    _profileImagePath = path;
    notifyListeners();
  }

  int getCartQuantity(String productId) {
    final item = _cartItems.where((i) => i.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }
}

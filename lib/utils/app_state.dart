import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../models/payment_account_model.dart';
import '../repositories/address_repository.dart';
import '../repositories/deal_repository.dart';
import '../constants/cloudinary_config.dart';

class AppState extends ChangeNotifier {
  static const String _cartStorageKey = 'cart_items';
  final AddressRepository _addressRepository = AddressRepository();
  final DealRepository _dealRepository = DealRepository();
  final _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  // ─── Cart ─────────────────────────────────────────────────────────────────
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalCartCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.total);

  double _freeDeliveryThreshold = 5000.0;
  double get freeDeliveryThreshold => _freeDeliveryThreshold;

  double _standardCharge = 80.0;
  double get standardCharge => _standardCharge;

  double _expressCharge = 150.0;
  double get expressCharge => _expressCharge;

  String _standardEta = '2-3 days';
  String get standardEta => _standardEta;

  String _expressEta = 'Same day';
  String get expressEta => _expressEta;

  bool _expressEnabled = true;
  bool get expressEnabled => _expressEnabled;

  double get deliveryFee =>
      cartSubtotal >= _freeDeliveryThreshold ? 0.0 : _standardCharge;

  double get cartTotal => cartSubtotal + deliveryFee;

  double get remainingForFreeDelivery {
    final remaining = _freeDeliveryThreshold - cartSubtotal;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> fetchDeliveryConfig() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('delivery_config')
          .select()
          .eq('id', 1)
          .maybeSingle();
      if (response != null) {
        _standardCharge = (response['standard_charge'] ?? 80).toDouble();
        _expressCharge = (response['express_charge'] ?? 150).toDouble();
        _freeDeliveryThreshold =
            (response['free_above_amount'] ?? 5000).toDouble();
        _standardEta = response['standard_eta'] ?? '2-3 days';
        _expressEta = response['express_eta'] ?? 'Same day';
        _expressEnabled = response['express_enabled'] ?? true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching delivery config: $e');
    }
  }

  /// Load persisted cart items from local storage.
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartStorageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        _cartItems.clear();
        _cartItems.addAll(decoded.map((e) => CartItem.fromJson(e)).toList());
        notifyListeners();
      }

      // Also load addresses and payment accounts
      await fetchAddresses();
      await fetchPaymentAccounts();
      await fetchActiveDeals();
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }

  /// Persist current cart items to local storage.
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          json.encode(_cartItems.map((e) => e.toJson()).toList());
      await prefs.setString(_cartStorageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  int getCartQuantity(String itemId) {
    final idx = _cartItems.indexWhere((e) => e.id == itemId);
    return idx >= 0 ? _cartItems[idx].quantity : 0;
  }

  void addToCart(Product product) {
    final idx =
        _cartItems.indexWhere((e) => !e.isDeal && e.product?.id == product.id);
    if (idx >= 0) {
      _cartItems[idx].quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
    _saveCart();
  }

  void addDealToCart(Deal deal) {
    final idx = _cartItems.indexWhere((e) => e.isDeal && e.deal?.id == deal.id);
    if (idx >= 0) {
      _cartItems[idx].quantity++;
    } else {
      _cartItems.add(CartItem(deal: deal));
    }
    notifyListeners();
    _saveCart();
  }

  void decreaseQuantity(String itemId) {
    final idx = _cartItems.indexWhere((e) => e.id == itemId);
    if (idx < 0) return;
    if (_cartItems[idx].quantity <= 1) {
      _cartItems.removeAt(idx);
    } else {
      _cartItems[idx].quantity--;
    }
    notifyListeners();
    _saveCart();
  }

  void removeFromCart(String itemId) {
    _cartItems.removeWhere((e) => e.id == itemId);
    notifyListeners();
    _saveCart();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveCart();
  }

  // ─── Orders ───────────────────────────────────────────────────────────────
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> fetchOrders() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      debugPrint('🕒 ORDERS: Fetching orders from Supabase...');
      if (user == null) {
        debugPrint('⚠️ ORDERS: No current user logged in. Skipping fetch.');
        return;
      }
      debugPrint('👤 ORDERS: Current User ID: ${user.id}');

      final response = await supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('time', ascending: false);

      debugPrint(
          '📩 ORDERS: Supabase response received. Type: ${response.runtimeType}');

      final List<dynamic> data = response as List<dynamic>;
      debugPrint('📊 ORDERS: Found ${data.length} total orders in database.');

      _orders.clear();

      for (var orderJson in data) {
        final List<dynamic> itemsJson = orderJson['order_items'] ?? [];
        final List<CartItem> items = itemsJson.map((item) {
          return CartItem(
            product: Product(
              id: '',
              name: item['product_name'] ?? 'Product',
              price: (item['price'] ?? 0).toDouble(),
              emoji: '📦',
              category: 'General',
              weight: '',
              stock: 0,
            ),
            quantity: item['quantity'] ?? 1,
          );
        }).toList();

        _orders.add(Order.fromJson(orderJson, items));
      }
      debugPrint(
          '✅ ORDERS: Successfully parsed and loaded ${_orders.length} orders into app state.');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> placeOrder({
    required String address,
    required String paymentMethod,
    required String deliverySpeed,
    String? paymentProofUrl,
    String? paymentAccountId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      String customerName = 'App User';

      if (user != null) {
        final profileRes = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        if (profileRes != null && profileRes['full_name'] != null) {
          customerName = profileRes['full_name'] as String;
        }
      }

      final amount = cartTotal;
      final orderNumber = _generateOrderId();

      final orderData = {
        'customer_name': customerName,
        'address': address,
        'amount': amount,
        'status': 'order Placed',
        'order_number': orderNumber,
        'delivery_type': deliverySpeed,
        'payment_method': paymentMethod,
        'payment_proof_url': paymentProofUrl,
        'payment_account_id': paymentAccountId,
        'user_id': user?.id,
      };

      debugPrint('📝 ORDERS: Submitting order data: $orderData');
      final orderResponse =
          await supabase.from('orders').insert(orderData).select().single();

      debugPrint('📦 ORDERS: Order inserted successfully. Res: $orderResponse');
      final String orderDbId = orderResponse['id'].toString();

      if (_cartItems.isNotEmpty) {
        final List<Map<String, dynamic>> itemsData = _cartItems
            .map((item) => {
                  'order_id': orderDbId,
                  'product_name': item.name,
                  'quantity': item.quantity,
                  'price': item.price,
                  'deal_id': item.isDeal ? item.id : null,
                })
            .toList();

        await supabase.from('order_items').insert(itemsData);
      }

      // Refresh orders list instead of just manual insertion to get all DB fields
      await fetchOrders();
      clearCart();
    } catch (e) {
      debugPrint('🚨 CRITICAL ERROR PLACING ORDER: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest Error Details: ${e.details}');
        debugPrint('Postgrest Error Message: ${e.message}');
        debugPrint('Postgrest Error Hint: ${e.hint}');
      }
    }
  }

  void updateOrderStatus(String orderId, int newStatus) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].statusIndex = newStatus;
      notifyListeners();
    }
  }

  // ─── Profile & Addresses ──────────────────────────────────────────────────
  List<Address> _addresses = [];
  bool _isAddressesLoading = false;

  List<Address> get addresses => List.unmodifiable(_addresses);
  bool get isAddressesLoading => _isAddressesLoading;

  String get deliveryAddress {
    final defaultAddr = _addresses.where((a) => a.isDefault).firstOrNull ??
        _addresses.firstOrNull;
    return defaultAddr?.location ?? 'No Address Provided';
  }

  Future<void> fetchAddresses() async {
    _isAddressesLoading = true;
    notifyListeners();

    _addresses = await _addressRepository.fetchAddresses();
    _isAddressesLoading = false;
    notifyListeners();
  }

  Future<void> addAddress(String name, String location) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final newAddress = Address(
      id: '', // Supabase will gen this
      userId: user.id,
      name: name,
      location: location,
      isDefault: _addresses.isEmpty, // Make default if it's the first one
    );

    final added = await _addressRepository.addAddress(newAddress);
    if (added != null) {
      if (added.isDefault) {
        // If it was meant to be default, ensure others aren't (though empty anyway)
        await _addressRepository.setDefaultAddress(added.id);
      }
      await fetchAddresses();
    }
  }

  Future<void> deleteAddress(String id) async {
    final success = await _addressRepository.deleteAddress(id);
    if (success) {
      await fetchAddresses();
    }
  }

  Future<void> setDefaultAddress(String id) async {
    final success = await _addressRepository.setDefaultAddress(id);
    if (success) {
      await fetchAddresses();
    }
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
  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().microsecondsSinceEpoch;
    return List.generate(6, (index) {
      return chars[(rnd + index * 31) % chars.length];
    }).join();
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ─── Online Payments ──────────────────────────────────────────────────────
  List<PaymentAccount> _paymentAccounts = [];
  bool _isPaymentAccountsLoading = false;

  List<PaymentAccount> get paymentAccounts => _paymentAccounts;
  bool get isPaymentAccountsLoading => _isPaymentAccountsLoading;

  Future<void> fetchPaymentAccounts() async {
    _isPaymentAccountsLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('payment_accounts')
          .select()
          .order('created_at', ascending: false);

      final List data = (response as List?) ?? [];
      _paymentAccounts = data.map((e) => PaymentAccount.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching payment accounts: $e');
    } finally {
      _isPaymentAccountsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadPaymentProof(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'payment_proofs'),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading payment proof to Cloudinary: $e');
      return null;
    }
  }

  // ─── Deals ────────────────────────────────────────────────────────────────
  List<Deal> _activeDeals = [];
  bool _isDealsLoading = false;

  List<Deal> get activeDeals => _activeDeals;
  bool get isDealsLoading => _isDealsLoading;

  Future<void> fetchActiveDeals() async {
    _isDealsLoading = true;
    notifyListeners();

    _activeDeals = await _dealRepository.getActiveDeals();
    _isDealsLoading = false;
    notifyListeners();
  }
}

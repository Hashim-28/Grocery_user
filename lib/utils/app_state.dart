import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AppState() {
    _initializeNotifications();
    requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final bool? granted = await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ??
          false; // Fixed: Uses the same plugin implementation pattern as the admin app
    }
    return true;
  }

  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'order_updates',
      'Order Updates',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _localNotificationsPlugin.show(
      id: notificationId,
      payload: notificationId.toString(),
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  // ─── Profile ──────────────────────────────────────────────────────────────
  String? _fullName;
  String? _email;
  String? _phone;
  String? _photoUrl;
  bool _isProfileLoading = false;

  String? get fullName => _fullName;
  String? get email => _email;
  String? get phone => _phone;
  String? get photoUrl => _photoUrl;
  bool get isProfileLoading => _isProfileLoading;

  Future<void> fetchProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      _isProfileLoading = true;
      notifyListeners();

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _fullName = response['full_name']?.toString();
        _email = response['email']?.toString();
        _phone = response['phone']?.toString();
        _photoUrl = response['photo_url']?.toString();
      } else {
        // Fallback to auth data if no profile entry exists yet
        _email = user.email;
        _phone = user.phone;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  void clearUserData() {
    _fullName = null;
    _email = null;
    _phone = null;
    _photoUrl = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? localImagePath,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      _isProfileLoading = true;
      notifyListeners();

      String? uploadedImageUrl = _photoUrl;

      // 1. Upload image to Cloudinary if provided
      if (localImagePath != null) {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            localImagePath,
            folder: 'user_profiles',
          ),
        );
        uploadedImageUrl = response.secureUrl;
      }

      int? parsedPhone;
      final phoneToSave = phone ?? _phone;
      if (phoneToSave != null && phoneToSave.isNotEmpty) {
        // Strip any non-numeric characters before parsing to BigInt
        parsedPhone = int.tryParse(phoneToSave.replaceAll(RegExp(r'[^0-9]'), ''));
      }

      // 2. Update profiles table
      final updateData = {
        'full_name': fullName ?? _fullName,
        'email': email ?? _email,
        'phone': parsedPhone,
        'photo_url': uploadedImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('profiles').upsert({
        'id': user.id,
        ...updateData,
      });

      // 3. Update local state
      _fullName = fullName ?? _fullName;
      _email = email ?? _email;
      _phone = phone ?? _phone;
      _photoUrl = uploadedImageUrl;

      debugPrint('✅ Profile updated successfully');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

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
      await fetchSupportData();
      await fetchProfile();
      await fetchNotifications();
      subscribeToOrderUpdates();
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }

  SharedPreferences? _prefs;
  /// Persist current cart items to local storage.
  Future<void> _saveCart() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonString =
          json.encode(_cartItems.map((e) => e.toJson()).toList());
      await _prefs!.setString(_cartStorageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  int getCartQuantity(String itemId) {
    final idx = _cartItems.indexWhere((e) => e.id == itemId);
    return idx >= 0 ? _cartItems[idx].quantity : 0;
  }

  void addToCart(Product product, {int quantity = 1}) {
    final idx =
        _cartItems.indexWhere((e) => !e.isDeal && e.product?.id == product.id);
    if (idx >= 0) {
      _cartItems[idx].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
    _saveCart();
  }

  void addDealToCart(Deal deal, {int quantity = 1}) {
    final idx = _cartItems.indexWhere((e) => e.isDeal && e.deal?.id == deal.id);
    if (idx >= 0) {
      _cartItems[idx].quantity += quantity;
    } else {
      _cartItems.add(CartItem(deal: deal, quantity: quantity));
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

      // Only fetch orders from the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final response = await supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .gte('time', thirtyDaysAgo.toIso8601String())
          .order('time', ascending: false);

      debugPrint(
          '📩 ORDERS: Supabase response received. Type: ${response.runtimeType}');

      final List<dynamic> data = response as List<dynamic>;
      debugPrint(
          '📊 ORDERS: Found ${data.length} orders from last 30 days in database.');

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
    required String phone,
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
        'customer_phone': phone,
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

      // Notify Admin
      _saveAdminNotificationToDb(
          '📦 New Order: #$orderNumber',
          'A new order has been placed by $customerName for ₨$amount.',
          'new_order');

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

  String get deliveryPhone {
    final defaultAddr = _addresses.where((a) => a.isDefault).firstOrNull ??
        _addresses.firstOrNull;
    return defaultAddr?.phone ?? _phone ?? '';
  }

  String get deliveryAddressName {
    final defaultAddr = _addresses.where((a) => a.isDefault).firstOrNull ??
        _addresses.firstOrNull;
    return defaultAddr?.name.toUpperCase() ?? 'ADDRESS';
  }

  Future<void> fetchAddresses() async {
    _isAddressesLoading = true;
    notifyListeners();

    _addresses = await _addressRepository.fetchAddresses();
    _isAddressesLoading = false;
    notifyListeners();
  }

  Future<void> addAddress(String name, String location, String phone) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final newAddress = Address(
      id: '', // Supabase will gen this
      userId: user.id,
      name: name,
      location: location,
      phone: phone,
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
  bool _isDarkMode = false;
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

  // ─── Support info ──────────────────────────────────────────────────────────
  List<Faq> _faqs = [];
  List<ContactDetail> _contactDetails = [];
  String _aboutApp = '';
  bool _isSupportLoading = false;

  List<Faq> get faqs => _faqs;
  List<ContactDetail> get contactDetails => _contactDetails;
  String get aboutApp => _aboutApp;
  bool get isSupportLoading => _isSupportLoading;

  Future<void> fetchSupportData() async {
    _isSupportLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;

      // Fetch FAQs
      final faqRes = await supabase.from('faqs').select();
      _faqs = (faqRes as List).map((e) => Faq.fromJson(e)).toList();

      // Fetch Contact Details
      final contactRes = await supabase.from('contact_details').select();
      _contactDetails =
          (contactRes as List).map((e) => ContactDetail.fromJson(e)).toList();

      // Fetch About App Info
      final aboutRes =
          await supabase.from('app_info').select().limit(1).maybeSingle();

      debugPrint('ℹ️ SUPPORT: About App Response: $aboutRes');

      if (aboutRes != null) {
        _aboutApp = aboutRes['content'] ?? '';
        debugPrint(
            '✅ SUPPORT: Loaded About App content length: ${_aboutApp.length}');
      } else {
        debugPrint('⚠️ SUPPORT: No record found in app_info table.');
      }
    } catch (e) {
      debugPrint('Error fetching support data: $e');
    } finally {
      _isSupportLoading = false;
      notifyListeners();
    }
  }

  // ─── Notifications ────────────────────────────────────────────────────────
  List<AppNotification> _notifications = [];
  bool _isNotificationsLoading = false;
  RealtimeChannel? _orderSubscription;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isNotificationsLoading => _isNotificationsLoading;

  Future<void> fetchNotifications() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      _isNotificationsLoading = true;
      notifyListeners();

      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List data = response as List;
      _notifications = data.map((e) => AppNotification.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isNotificationsLoading = false;
      notifyListeners();
    }
  }

  void subscribeToOrderUpdates() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _orderSubscription?.unsubscribe();

    _orderSubscription = supabase
        .channel('order_updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final newStatus = payload.newRecord['status'];
            final oldStatus = payload.oldRecord['status'];
            final orderNumber = payload.newRecord['order_number'];

            if (newStatus != oldStatus) {
              final title = 'Order Update: $orderNumber';
              final body = 'Your order status has been updated to "$newStatus"';

              showLocalNotification(title, body);

              // Save to database
              _saveNotificationToDb(title, body, 'order_update');

              // Refresh local data
              fetchOrders();
              fetchNotifications();
            }
          },
        )
        .subscribe();
  }

  Future<void> _saveNotificationToDb(
      String title, String body, String type) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('notifications').insert({
        'user_id': user.id,
        'title': title,
        'body': body,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Error saving notification to DB: $e');
    }
  }

  Future<void> _saveAdminNotificationToDb(
      String title, String body, String type) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('admin_notifications').insert({
        'title': title,
        'body': body,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Error saving admin notification: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase
          .from('notifications')
          .update({'is_read': true}).eq('user_id', user.id);

      await fetchNotifications();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  Future<void> clearNotifications() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('notifications').delete().eq('user_id', user.id);
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  // ─── Location ─────────────────────────────────────────────────────────────

  Future<String?> getCurrentLocationAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocode to get address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.subLocality}, ${place.locality}";
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
    return null;
  }

  // ─── Reviews ──────────────────────────────────────────────────────────────
  List<Review> _reviews = [];
  bool _isReviewsLoading = false;

  List<Review> get reviews => List.unmodifiable(_reviews);
  bool get isReviewsLoading => _isReviewsLoading;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    int sum = 0;
    for (var review in _reviews) {
      sum += review.rating;
    }
    return sum / _reviews.length;
  }

  Future<void> fetchReviews(String productId) async {
    _isReviewsLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final List data = response as List;
      _reviews = data.map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    } finally {
      _isReviewsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview({
    required String productId,
    required int rating,
    String? comment,
    String? localImagePath,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      _isReviewsLoading = true;
      notifyListeners();

      String userName = 'App User';
      final profileRes = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      
      if (profileRes != null && profileRes['full_name'] != null) {
        userName = profileRes['full_name'];
      } else if (user.email != null) {
         userName = user.email!.split('@')[0];
      }

      String? uploadedImageUrl;

      if (localImagePath != null) {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            localImagePath,
            folder: 'product_reviews',
          ),
        );
        uploadedImageUrl = response.secureUrl;
      }

      final reviewData = {
        'product_id': productId,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
        'image_url': uploadedImageUrl,
      };

      await supabase.from('reviews').insert(reviewData);
      
      // Refresh reviews
      await fetchReviews(productId);
      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      return false;
    } finally {
      if (_isReviewsLoading) {
         _isReviewsLoading = false;
         notifyListeners();
      }
    }
  }
}

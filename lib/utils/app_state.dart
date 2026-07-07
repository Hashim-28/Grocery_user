import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import '../models/payment_account_model.dart';
import '../repositories/address_repository.dart';
import '../repositories/deal_repository.dart';
import 'supabase_config.dart';
import '../services/push_notification_service.dart';
import '../services/notification_api_service.dart';


class AppState extends ChangeNotifier {
  static const String _cartStorageKey = 'cart_items';
  final AddressRepository _addressRepository = AddressRepository();
  final DealRepository _dealRepository = DealRepository();


  AppState() {
    // Notifications are initialized in main.dart via PushNotificationService
  }



  Future<void> showLocalNotification(String title, String body) async {
    await PushNotificationService().showLocalNotification(title, body);
  }

  // ─── Guest Mode ───────────────────────────────────────────────────────────
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  void setGuestMode(bool value) {
    _isGuest = value;
    notifyListeners();
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
        
        // Ensure FCM token is synced when profile is fetched
        PushNotificationService().updateToken();
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

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🚀 GOOGLE AUTH: Starting process...');
      _isProfileLoading = true;
      notifyListeners();

      // 1. Trigger Google Sign-In
      debugPrint('📍 GOOGLE AUTH: Calling authenticate()...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        debugPrint('⚠️ GOOGLE AUTH: User cancelled the sign-in picker.');
        _isProfileLoading = false;
        notifyListeners();
        return;
      }
      debugPrint('✅ GOOGLE AUTH: Picker successful. User: ${googleUser.email}');

      // 2. Get Authentication details
      debugPrint('📍 GOOGLE AUTH: Retrieving authentication details...');
      final googleAuth = googleUser.authentication;
      debugPrint('✅ GOOGLE AUTH: Authentication retrieved. idToken is ${googleAuth.idToken != null ? 'PRESENT' : 'NULL'}');
      
      // Get Access Token via authorizationClient
      debugPrint('📍 GOOGLE AUTH: Requesting scopes for access token...');
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      debugPrint('✅ GOOGLE AUTH: Scopes authorized. accessToken is ${clientAuth.accessToken != null ? 'PRESENT' : 'NULL'}');

      // 3. Auth with Firebase
      debugPrint('📍 GOOGLE AUTH: Signing into Firebase...');
      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final fbUserRes = await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('✅ GOOGLE AUTH: Firebase login successful. User: ${fbUserRes.user?.uid}');

      // 4. Auth with Supabase (the "sync")
      if (googleAuth.idToken != null) {
        debugPrint('📍 GOOGLE AUTH: Syncing with Supabase...');
        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
        );
        debugPrint('✅ GOOGLE AUTH: Supabase sync successful.');
      } else {
        debugPrint('⚠️ GOOGLE AUTH: idToken is null, skipping Supabase sync.');
      }

      // 5. Update profile and fetch data
      debugPrint('📍 GOOGLE AUTH: Fetching profile from Supabase...');
      await fetchProfile();
      
      // If profile doesn't exist or is missing name, update it from Google data
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && (_fullName == null || _fullName!.isEmpty)) {
        debugPrint('📍 GOOGLE AUTH: Profile missing details, updating with Google data...');
        await updateProfile(
          fullName: googleUser.displayName,
          email: googleUser.email,
        );
        debugPrint('✅ GOOGLE AUTH: Profile updated successfully.');
      }
      debugPrint('🏁 GOOGLE AUTH: Process completed successfully.');

    } catch (e, stack) {
      debugPrint('❌ GOOGLE AUTH ERROR: $e');
      debugPrint('📚 STACK TRACE: $stack');
      rethrow;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
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

      // 1. Upload image to Supabase Storage if provided
      if (localImagePath != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(localImagePath)}';
        final storagePath = 'user_profiles/$fileName';
        await supabase.storage.from(SupabaseConfig.storageBucket).upload(
              storagePath,
              File(localImagePath),
            );
        uploadedImageUrl = supabase.storage.from(SupabaseConfig.storageBucket).getPublicUrl(storagePath);
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

      _saveAdminNotificationToDb(
          '📦 New Order: #$orderNumber',
          'A new order has been placed by $customerName for ₨$amount.',
          'new_order');

      // Trigger Push Notification for Admins
      NotificationApiService().notifyAdmins(
        title: '📦 New Order Received!',
        body: 'Order #$orderNumber from $customerName',
        data: {'orderId': orderNumber, 'type': 'new_order'},
      );

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
      final supabase = Supabase.instance.client;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';
      final storagePath = 'payment_proofs/$fileName';
      await supabase.storage.from(SupabaseConfig.storageBucket).upload(
            storagePath,
            imageFile,
          );
      return supabase.storage.from(SupabaseConfig.storageBucket).getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Error uploading payment proof to Supabase Storage: $e');
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
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${localImagePath.split('\\').last}';
        final storagePath = 'product_reviews/$fileName';
        await supabase.storage.from('grocery-storage').upload(
              storagePath,
              File(localImagePath),
            );
        uploadedImageUrl = supabase.storage.from('grocery-storage').getPublicUrl(storagePath);
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

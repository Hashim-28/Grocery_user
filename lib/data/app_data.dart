import '../models/models.dart';

class AppData {
  static final List<Map<String, dynamic>> categories = [
    {
      'name': 'Atta & Grains',
      'emoji': '🌾',
      'color': 0xFFE7F0DC,
      'image': 'https://images.unsplash.com/photo-1501265976582-c1e1b0bbaf63?auto=format&fit=crop&q=80&w=400'
    },
    {
      'name': 'Fresh Sabzi',
      'emoji': '🥦',
      'color': 0xFFF1F8E9,
      'image': 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?auto=format&fit=crop&q=80&w=400'
    },
    {
      'name': 'Pure Dairy',
      'emoji': '🥛',
      'color': 0xFFECF9FF,
      'image': 'https://images.unsplash.com/photo-1563636619-e9107da5a766?auto=format&fit=crop&q=80&w=400'
    },
    {
      'name': 'Fresh Meat',
      'emoji': '🥩',
      'color': 0xFFFFF2F2,
      'image': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&q=80&w=400'
    },
    {
      'name': 'Bakery',
      'emoji': '🥐',
      'color': 0xFFFFF8E1,
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&q=80&w=400'
    },
  ];

  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'n1',
      'title': 'Order Dispatched! 🚚',
      'body': 'Your order #1234 is on the way with our rider.',
      'time': '2 mins ago',
      'isRead': false,
      'type': 'order'
    },
    {
      'id': 'n2',
      'title': '20% OFF on Bakery 🥐',
      'body': 'Enjoy flat 20% discount on all bakery items today.',
      'time': '1 hour ago',
      'isRead': false,
      'type': 'promo'
    },
    {
      'id': 'n3',
      'title': 'Order Delivered 🏠',
      'body': 'Your order #1230 has been successfully delivered.',
      'time': 'Yesterday',
      'isRead': true,
      'type': 'order'
    },
  ];

  static final List<Product> products = [
    Product(
      id: 'p1',
      name: '5kg Aashirvaad Atta',
      category: 'Atta & Grains',
      weight: 'Premium Whole Wheat Flour',
      price: 850,
      stock: 45,
      emoji: '🌾',
      isBestSeller: true,
      imageUrl: 'https://m.media-amazon.com/images/I/81vR9h49n0L._SL1500_.jpg',
      description: 'High-quality whole wheat flour, perfect for soft and fluffy rotis.',
    ),
    Product(
      id: 'p2',
      name: '1kg Tomatoes',
      category: 'Fresh Sabzi',
      weight: 'Fresh Farm-Picked',
      price: 120,
      originalPrice: 150,
      isDiscounted: true,
      stock: 12,
      emoji: '🍅',
      isBestSeller: true,
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&q=80&w=400',
      description: 'Juicy, red, farm-fresh tomatoes. Buy 1 Get 1 Free deal applicable.',
    ),
    Product(
      id: 'p3',
      name: '2.5L Dalda Cooking Oil',
      category: 'Atta & Grains',
      weight: 'Vitamin Enriched 2.5L',
      price: 1450,
      stock: 35,
      emoji: '🏺',
      isBestSeller: true,
      imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&q=80&w=400',
    ),
    Product(
      id: 'p4',
      name: '1kg Onions',
      category: 'Fresh Sabzi',
      weight: 'Grade-A Export Quality',
      price: 95,
      originalPrice: 120,
      isDiscounted: true,
      stock: 100,
      emoji: '🧅',
      imageUrl: 'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&q=80&w=400',
    ),
    Product(
      id: 'p5',
      name: 'Basmati Rice 5kg',
      category: 'Atta & Grains',
      weight: 'Super Kernel Aged Rice',
      price: 1850,
      stock: 60,
      emoji: '🍚',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=400',
    ),
    Product(
      id: 'p6',
      name: 'MilkPak 1L (Carton)',
      category: 'Pure Dairy',
      weight: 'Pack of 12 Tetrapaks',
      price: 2120,
      stock: 10,
      emoji: '🥛',
      imageUrl: 'https://images.unsplash.com/photo-1550583724-125581fe2f8a?auto=format&fit=crop&q=80&w=400',
    ),
    Product(
      id: 'p7',
      name: 'Farm Fresh Eggs',
      category: 'Pure Dairy',
      weight: 'Dozen',
      price: 320,
      stock: 50,
      emoji: '🥚',
      isBestSeller: true,
      imageUrl: 'https://images.unsplash.com/photo-1582722872445-44ad5c78af47?auto=format&fit=crop&q=80&w=400',
    ),
    Product(
      id: 'p8',
      name: 'Fresh Croissant',
      category: 'Bakery',
      weight: 'Buttery & Flaky (2pcs)',
      price: 240,
      originalPrice: 300,
      isDiscounted: true,
      stock: 20,
      emoji: '🥐',
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&q=80&w=400',
    ),
    Product(
      id: 'p9',
      name: 'Chocolate Brownie',
      category: 'Bakery',
      weight: 'Fudgey & Rich (4pcs)',
      price: 480,
      originalPrice: 600,
      isDiscounted: true,
      stock: 15,
      emoji: '🍩',
      imageUrl: 'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&q=80&w=400',
    ),
  ];

  static final List<Map<String, dynamic>> deals = [
    {
      'title': 'FLASH SALE',
      'subtitle': 'Flat 20% Off on All Bakery',
      'validUntil': 'Valid until midnight',
      'emoji': '🥐',
      'color': 0xFF2E7D32,
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&q=80&w=600',
    },
    {
      'title': 'DAILY DEAL',
      'subtitle': 'Buy 1 Get 1 Free on Veggies',
      'validUntil': 'Limited time only',
      'emoji': '🥦',
      'color': 0xFFEF6C00,
      'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&q=80&w=600',
    },
  ];

  static final List<Map<String, String>> orderStatuses = [
    {
      'title': 'Order Received',
      'subtitle': 'We have received your order and are verifying details.',
      'icon': '📝'
    },
    {
      'title': 'Order Preparing',
      'subtitle': 'Our staff is hand-picking the best items for you.',
      'icon': '🧺'
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Your order is on the way with our rider.',
      'icon': '🏍️'
    },
    {
      'title': 'Delivered',
      'subtitle': 'Order successfully delivered. Enjoy your groceries!',
      'icon': '🏠'
    },
  ];

  static final List<Map<String, String>> paymentMethods = [
    {
      'id': 'jazzcash',
      'name': 'JazzCash',
      'subtitle': 'Pay using JazzCash Mobile Wallet',
      'icon': '📱',
    },
    {
      'id': 'easypaisa',
      'name': 'EasyPaisa',
      'subtitle': 'Pay using EasyPaisa Wallet or App',
      'icon': '💡',
    },
    {
      'id': 'cod',
      'name': 'Cash on Delivery',
      'subtitle': 'Pay when you receive your order',
      'icon': '💵',
    },
  ];
}

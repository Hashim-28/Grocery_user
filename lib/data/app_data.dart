import '../models/models.dart';

class AppData {
  // ─── Categories ───────────────────────────────────────────────────────────
  static const List<Category> categories = [
    Category(
      id: 'c1',
      name: 'Atta & Grains',
      emoji: '🌾',
      color: 0xFFFFF8E1,
      imageUrl: 'assets/images/atta.jpg',
    ),
    Category(
      id: 'c2',
      name: 'Fresh Sabzi',
      emoji: '🥦',
      color: 0xFFE8F5E9,
      imageUrl: 'assets/images/vagitables.jpg',
    ),
    Category(
      id: 'c3',
      name: 'Pure Dairy',
      emoji: '🥛',
      color: 0xFFE3F2FD,
      imageUrl: 'assets/images/milk.jpg',
    ),
    Category(
      id: 'c4',
      name: 'Fresh Meat',
      emoji: '🥩',
      color: 0xFFFFEBEE,
      imageUrl: 'assets/images/meat.jpg',
    ),
    Category(
      id: 'c5',
      name: 'Bakery',
      emoji: '🥐',
      color: 0xFFFFF3E0,
      imageUrl: 'assets/images/bakery.jpg',
    ),
    Category(
      id: 'c6',
      name: 'Beverages',
      emoji: '🧃',
      color: 0xFFF3E5F5,
      imageUrl:
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&q=80&w=400',
    ),
    Category(
      id: 'c7',
      name: 'Snacks',
      emoji: '🍿',
      color: 0xFFE0F7FA,
      imageUrl:
          'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&q=80&w=400',
    ),
    Category(
      id: 'c8',
      name: 'Cooking Oils',
      emoji: '🏺',
      color: 0xFFFCE4EC,
      imageUrl:
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&q=80&w=400',
    ),
  ];

  // ─── Exclusive Promotions (Top Carousel) ──────────────────────────────────
  static const List<Promotion> promotions = [];

  // ─── Products ─────────────────────────────────────────────────────────────
  static const List<Product> products = [
    Product(
      id: 'p1',
      name: '5kg Aashirvaad Atta',
      category: 'Atta & Grains',
      emoji: '🌾',
      weight: '5 kg bag',
      price: 850,
      stock: 45,
      isBestSeller: true,
      // imageUrl: 'assets/images/atta.jpg',
      description:
          'High-quality whole wheat flour. Perfect for soft and fluffy rotis. Sourced from premium wheat farms.',
    ),
    Product(
      id: 'p2',
      name: '1kg Ripe Tomatoes',
      category: 'Fresh Sabzi',
      emoji: '🍅',
      weight: '1 kg fresh',
      price: 120,
      originalPrice: 160,
      stock: 12,
      isBestSeller: true,
      isDiscounted: true,
      // imageUrl: 'assets/images/produce.png',
      description:
          'Farm-fresh, juicy red tomatoes. Hand-picked for peak ripeness and flavour. Great for curries and salads.',
    ),
    Product(
      id: 'p3',
      name: '2.5L Dalda Cooking Oil',
      category: 'Cooking Oils',
      emoji: '🏺',
      weight: '2.5 L bottle',
      price: 1450,
      stock: 35,
      isBestSeller: true,
      // imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&q=80&w=400',
      description:
          'Refined cooking oil, enriched with vitamins A, D, and E. Ideal for deep frying and everyday cooking.',
    ),
    Product(
      id: 'p4',
      name: '1kg Grade-A Onions',
      category: 'Fresh Sabzi',
      emoji: '🧅',
      weight: '1 kg mesh bag',
      price: 95,
      originalPrice: 130,
      stock: 100,
      isDiscounted: true,
      // imageUrl: 'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&q=80&w=400',
      description:
          'Export-quality red onions with a sharp, pungent flavour. A staple for Pakistani cooking.',
    ),
    Product(
      id: 'p5',
      name: 'Super Kernel Rice 5kg',
      category: 'Atta & Grains',
      emoji: '🍚',
      weight: '5 kg bag',
      price: 1850,
      stock: 60,
      isBestSeller: true,
      // imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=400',
      description:
          'Aged super basmati rice with long, non-sticky grains. Perfect for biryani, pulao, and everyday use.',
    ),
    Product(
      id: 'p6',
      name: 'MilkPak UHT 1L ×12',
      category: 'Pure Dairy',
      emoji: '🥛',
      weight: 'Carton of 12',
      price: 2120,
      stock: 10,
      isBestSeller: true,
      // imageUrl: 'assets/images/milk.jpg',
      description:
          'Full-cream UHT pasteurised milk. No additives, no preservatives. Shelf-stable for up to 6 months.',
    ),
    Product(
      id: 'p7',
      name: 'Farm Fresh Eggs Dozen',
      category: 'Pure Dairy',
      emoji: '🥚',
      weight: '1 dozen (12 pcs)',
      price: 320,
      stock: 50,
      isBestSeller: true,
      // imageUrl: 'assets/images/eggs.jpg',
      description:
          'Free-range, protein-rich eggs sourced daily from local farms. Rich yolks and strong shells.',
    ),
    Product(
      id: 'p8',
      name: 'Butter Croissant 2pcs',
      category: 'Bakery',
      emoji: '🥐',
      weight: '2 pieces (180g)',
      price: 240,
      originalPrice: 300,
      stock: 20,
      isDiscounted: true,
      // imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&q=80&w=400',
      description:
          'Flaky, buttery French-style croissants baked fresh daily. Best enjoyed warm with preserves.',
    ),
    Product(
      id: 'p9',
      name: 'Chocolate Brownie 4pcs',
      category: 'Bakery',
      emoji: '🍩',
      weight: '4 pieces (320g)',
      price: 480,
      originalPrice: 600,
      stock: 15,
      isDiscounted: true,
      // imageUrl: 'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&q=80&w=400',
      description:
          'Dense, fudgey Belgian chocolate brownies. Baked fresh with 70% dark chocolate and walnuts.',
    ),
    Product(
      id: 'p10',
      name: 'Fresh Broccoli 500g',
      category: 'Fresh Sabzi',
      emoji: '🥦',
      weight: '500g head',
      price: 180,
      stock: 25,
      // imageUrl: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&q=80&w=400',
      description:
          'Fresh, crisp broccoli florets. High in fibre, vitamins C and K. Great for stir-fries and steaming.',
    ),
    Product(
      id: 'p11',
      name: 'Nestle Milo 400g',
      category: 'Beverages',
      emoji: '🧃',
      weight: '400g tin',
      price: 750,
      stock: 40,
      // imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&q=80&w=400',
      description:
          'Malted chocolate drink mix fortified with 9 vitamins and 5 minerals. A favourite breakfast drink.',
    ),
    Product(
      id: 'p12',
      name: 'Lays Classic Chips',
      category: 'Snacks',
      emoji: '🍿',
      weight: '162g large pack',
      price: 220,
      originalPrice: 270,
      stock: 80,
      isDiscounted: true,
      // imageUrl: 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&q=80&w=400',
      description:
          'Crispy, light classic salted potato chips. The perfect companion for any occasion.',
    ),
  ];

  // ─── Order Statuses ───────────────────────────────────────────────────────
  static const List<Map<String, String>> orderStatuses = [
    {
      'title': 'Order Placed',
      'subtitle': 'Your order has been received and is being verified.',
      'icon': '📝',
      'time': '',
    },
    {
      'title': 'Order Confirmed',
      'subtitle': 'Our team has confirmed your order details.',
      'icon': '✅',
      'time': '',
    },
    {
      'title': 'Items Being Packed',
      'subtitle': 'Our staff is carefully hand-picking your items.',
      'icon': '📦',
      'time': '',
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Our rider is on the way with your order.',
      'icon': '🏍️',
      'time': '',
    },
    {
      'title': 'Delivered',
      'subtitle': 'Your order has been successfully delivered. Enjoy!',
      'icon': '🏠',
      'time': '',
    },
  ];

  // ─── Payment Methods ──────────────────────────────────────────────────────
  static const List<Map<String, String>> paymentMethods = [
    {
      'id': 'cod',
      'name': 'Cash on Delivery',
      'subtitle': 'Pay in cash when your order arrives',
      'icon': '💵',
    },
  ];
}

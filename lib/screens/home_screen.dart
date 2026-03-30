import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import 'product_list_screen.dart';
import 'categories_screen.dart';
import 'product_detail_screen.dart';
import 'main_navigation.dart';
import 'notifications_screen.dart';
import '../widgets/search_delegate.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_bar.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dealIndex = 0;

  @override
  Widget build(BuildContext context) {
    final popularProducts =
        AppData.products.where((p) => p.isBestSeller).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),
                // Search Bar
                SliverToBoxAdapter(child: _buildSearchBar(context)),
                // Deals Section
                SliverToBoxAdapter(child: _buildDeals()),
                // Categories Section
                SliverToBoxAdapter(child: _buildCategories(context)),
                // Popular Products
                SliverToBoxAdapter(child: _buildSectionHeader('Popular Products', showSeeAll: true)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ProductCard(
                        product: popularProducts[i],
                        appState: widget.appState,
                      ),
                      childCount: popularProducts.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            ListenableBuilder(
              listenable: widget.appState,
              builder: (context, _) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CartBar(appState: widget.appState),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.brandGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'DELIVERING TO',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Gulberg III, Lahore',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textDark, size: 24),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark, size: 24),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.redBadge,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: GestureDetector(
        onTap: () => showSearch(
          context: context,
          delegate: ProductSearchDelegate(appState: widget.appState),
        ),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 24),
              const SizedBox(width: 14),
              Text(
                'Search "MilkPak"',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Deals of the Day', showSeeAll: true),
        SizedBox(
          height: 170,
          child: PageView.builder(
            itemCount: AppData.deals.length,
            controller: PageController(viewportFraction: 0.92),
            onPageChanged: (i) => setState(() => _dealIndex = i),
            itemBuilder: (_, i) {
              final deal = AppData.deals[i];
              return GestureDetector(
                onTap: () {
                  bool showOnlyDiscounted = deal['title'].contains('SALE') || deal['title'].contains('DEAL');
                  String category = deal['title'].contains('Bakery') 
                    ? 'Bakery' 
                    : (deal['subtitle'].contains('Veggies') ? 'Fresh Sabzi' : 'All');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(
                        appState: widget.appState,
                        categoryName: category,
                        showOnlyDiscounted: showOnlyDiscounted,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Color(deal['color']).withOpacity(0.9),
                        Color(deal['color']),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(deal['image']),
                      fit: BoxFit.cover,
                      opacity: 0.25,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            deal['title'],
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          deal['subtitle'],
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          deal['validUntil'] ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = AppData.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Browse Categories'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _categoryCard(categories[0])),
                  const SizedBox(width: 12),
                  Expanded(child: _categoryCard(categories[1])),
                  const SizedBox(width: 12),
                  Expanded(child: _categoryCard(categories[2])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _categoryCard(categories[3])),
                  const SizedBox(width: 12),
                  Expanded(child: _categoryCard(categories[4])),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListScreen(
            appState: widget.appState,
            categoryName: cat['name'],
          ),
        ),
      ),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Color(cat['color']),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cat['emoji'],
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              cat['name'].replaceAll(' & ', '\n'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(
                      appState: widget.appState,
                      categoryName: 'All',
                    ),
                  ),
                );
              },
              child: Text(
                'See all',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.brandGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final AppState appState;
  ProductSearchDelegate({required this.appState});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: AppTheme.textDark),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = AppData.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              'No products found for "$query"',
              style: GoogleFonts.outfit(
                color: AppTheme.textMedium,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) => ProductCard(
        product: results[i],
        appState: appState,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = AppData.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: suggestions[i].imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(suggestions[i].imageUrl!, fit: BoxFit.cover),
                )
              : Center(child: Text(suggestions[i].emoji, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(
          suggestions[i].name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Text(
          '₨${suggestions[i].price.toInt()} · ${suggestions[i].category}',
          style: GoogleFonts.outfit(color: AppTheme.textLight, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          query = suggestions[i].name;
          showResults(context);
        },
      ),
    );
  }
}

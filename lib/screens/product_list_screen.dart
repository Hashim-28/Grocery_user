import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import 'product_detail_screen.dart';
import 'main_navigation.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_bar.dart';
import '../widgets/search_delegate.dart';

class ProductListScreen extends StatefulWidget {
  final AppState appState;
  final String categoryName;
  final bool showOnlyDiscounted;
  const ProductListScreen({
    super.key,
    required this.appState,
    required this.categoryName,
    this.showOnlyDiscounted = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedCategory = "All";
  String _sortBy = "Default";

  List<Product> get _filteredProducts {
    List<Product> baseListing = widget.showOnlyDiscounted 
        ? AppData.products.where((p) => p.isDiscounted).toList()
        : AppData.products;

    List<Product> filtered = _selectedCategory == "All" 
        ? List.from(baseListing)
        : baseListing.where((p) => p.category == _selectedCategory).toList();
    
    if (_sortBy == "Price: Low to High") {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == "Price: High to Low") {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }
    
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = widget.appState.totalCartCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diesel Cash & Carry',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Freshness delivered to your doorstep.',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppTheme.brandGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.textDark),
            onPressed: () => showSearch(
              context: context,
              delegate: ProductSearchDelegate(appState: widget.appState),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textDark),
            onPressed: () => _showFilterSheet(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildTabs(),
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.58,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (_, i) {
              return ProductCard(
                product: _filteredProducts[i],
                appState: widget.appState,
              );
            },
          ),
          ListenableBuilder(
            listenable: widget.appState,
            builder: (context, _) => Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartBar(appState: widget.appState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final categories = ["All", ...AppData.categories.map((c) => c['name'])];
    return Container(
      color: Colors.white,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          bool isSelected = _selectedCategory == categories[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = categories[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.brandGreen : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppTheme.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort Products',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 20),
              _sortOption("Default"),
              _sortOption("Price: Low to High"),
              _sortOption("Price: High to Low"),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOption(String title) {
    bool isSelected = _sortBy == title;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        setState(() => _sortBy = title);
        Navigator.pop(context);
      },
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppTheme.brandGreen : AppTheme.textDark,
        ),
      ),
      trailing: isSelected 
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.brandGreen) 
          : null,
    );
  }
}

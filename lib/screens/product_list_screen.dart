import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../data/app_data.dart';
import '../../models/models.dart';
import 'main_navigation.dart';
import '../../widgets/product_card.dart';
import '../../widgets/cart_bar.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class ProductListScreen extends StatefulWidget {
  final AppState appState;
  final String? categoryName;
  final String? searchQuery;
  final bool showOnlyDiscounted;

  const ProductListScreen({
    super.key,
    required this.appState,
    this.categoryName,
    this.searchQuery,
    this.showOnlyDiscounted = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _activeCategory = 'All';

  @override
  void initState() {
    super.initState();
    _activeCategory = widget.categoryName ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Products';
    if (widget.searchQuery != null) title = 'Search "${widget.searchQuery}"';
    if (widget.showOnlyDiscounted) title = 'Hot Deals';

    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        final products = dataProvider.products.where((p) {
          if (widget.searchQuery != null) {
            if (!p.name.toLowerCase().contains(widget.searchQuery!.toLowerCase())) {
              return false;
            }
          }
          if (_activeCategory != 'All' && p.category != _activeCategory) {
            return false;
          }
          if (widget.showOnlyDiscounted && !p.hasDiscount) {
            return false;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
          ),
          body: Column(
            children: [
              if (widget.searchQuery == null && !widget.showOnlyDiscounted)
                SizedBox(
                  height: 54,
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(2),
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    interactive: true,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _activeCategory == 'All',
                          onTap: () => setState(() => _activeCategory = 'All'),
                        ),
                        ...dataProvider.categories.map((c) => _FilterChip(
                          label: c.name,
                          isSelected: _activeCategory == c.name,
                          onTap: () => setState(() => _activeCategory = c.name),
                        )),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    if (dataProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (products.isEmpty)
                      const Center(child: Text('No products found'))
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: products.length,
                            itemBuilder: (_, i) => ProductCard(
                              product: products[i],
                              appState: widget.appState,
                            ),
                          );
                        },
                      ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: CartBar(
                        appState: widget.appState,
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          AppRouter.fade(MainNavigation(appState: widget.appState, initialIndex: 2)),
                          (r) => false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: AppTheme.surfaceVariant,
        selectedColor: AppTheme.primary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          color: isSelected ? Colors.white : AppTheme.textHeading,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1,
          ),
        ),
      ),
    );
  }
}

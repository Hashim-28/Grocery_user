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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            title: Text(title, style: TextStyle(fontSize: 20.sp)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              if (widget.searchQuery == null && !widget.showOnlyDiscounted)
                SizedBox(
                  height: 54.h,
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 4.r,
                    radius: Radius.circular(2.r),
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    interactive: true,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
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
              SizedBox(height: 12.h),
              Expanded(
                child: Stack(
                  children: [
                    if (dataProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (products.isEmpty)
                      Center(child: Text('No products found', style: TextStyle(fontSize: 14.sp)))
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
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
                      left: 20.w,
                      right: 20.w,
                      bottom: 20.h,
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
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: AppTheme.surfaceVariant,
        selectedColor: AppTheme.primary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.sp,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          color: isSelected ? Colors.white : AppTheme.textHeading,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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

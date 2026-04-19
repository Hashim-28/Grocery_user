import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../data/app_data.dart';
import '../../models/models.dart';
import '../../widgets/product_card.dart';
import 'categories_screen.dart';
import 'product_list_screen.dart';
import '../widgets/search_delegate.dart';
import 'location_picker_screen.dart';
import 'notifications_screen.dart';
import '../widgets/core/app_widgets.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/deal_model.dart' as dm;
import 'deal_detail_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = SearchController();
  int _dealIndex = 0;
  String? _selectedCategoryName;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Removed deprecated _search function that used showSearch

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        final products = _selectedCategoryName == null
            ? dataProvider.products
            : dataProvider.products
                .where((p) => p.category == _selectedCategoryName)
                .toList();

        final popular = products.where((p) => p.isBestSeller).toList();
        // If no best sellers in filtered list, show all filtered products
        final displayProducts = popular.isEmpty ? products : popular;

        return Scaffold(
          backgroundColor:
              widget.appState.isDarkMode ? AppTheme.scaffold : Colors.white,
          body: Stack(
            children: [
              // Background Glows
              Positioned(
                top: -100,
                left: -100,
                child: widget.appState.isDarkMode
                    ? _buildBackgroundGlow(
                        AppTheme.primary.withOpacity(0.1), 300)
                    : const SizedBox.shrink(),
              ),
              Positioned(
                top: 400,
                right: -150,
                child: widget.appState.isDarkMode
                    ? _buildBackgroundGlow(
                        AppTheme.accent.withOpacity(0.1), 400)
                    : const SizedBox.shrink(),
              ),

              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(
                        child: _buildSearchBar(dataProvider.products)),
                    SliverToBoxAdapter(child: _buildDeals(dataProvider)),
                    SliverToBoxAdapter(child: _buildCategories(dataProvider)),
                    if (dataProvider.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (displayProducts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No products found',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textMuted),
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(child: _buildPopular(displayProducts)),
                    const SliverPadding(
                        padding: EdgeInsets.only(
                            bottom: 120)), // Space for bottom nav
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: AppTheme.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'DELIVERING TO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    AppRouter.slideFade(
                        LocationPickerScreen(appState: widget.appState)),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: ListenableBuilder(
                          listenable: widget.appState,
                          builder: (context, _) => Text(
                            widget.appState.deliveryAddress.split(',')[0],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textHeading,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.primary, size: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              AppRouter.slideFade(const NotificationsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.glassBorder, width: 1),
              ),
              child: Icon(Icons.notifications_none_rounded,
                  color: AppTheme.textHeading, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SearchAnchor(
        // controller: _searchCtrl,
        viewBackgroundColor:
            widget.appState.isDarkMode ? AppTheme.scaffold : Colors.white,
        // viewSurfaceTint: Colors.transparent,
        builder: (context, controller) {
          return GestureDetector(
            onTap: () => controller.openView(),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.appState.isDarkMode
                    ? AppTheme.surfaceVariant.withOpacity(0.8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.appState.isDarkMode
                      ? AppTheme.glassBorder
                      : AppTheme.border.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(widget.appState.isDarkMode ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: widget.appState.isDarkMode
                          ? AppTheme.primary
                          : AppTheme.primary,
                      size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.text.isEmpty
                          ? 'Search for fresh groceries...'
                          : controller.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: controller.text.isEmpty
                            ? AppTheme.textMuted
                            : AppTheme.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.neonShadow,
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          );
        },
        suggestionsBuilder: (context, controller) {
          final query = controller.text.toLowerCase();
          final products_list = products
              .where((p) => p.name.toLowerCase().contains(query))
              .take(8)
              .toList();

          final List<Widget> items = [];

          if (query.isNotEmpty) {
            // First item: Search for query
            items.add(ListTile(
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.search_rounded, color: AppTheme.primary),
              ),
              title: Text(
                'Search for "${controller.text}"',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppTheme.primary),
              onTap: () {
                controller.closeView(controller.text);
                Navigator.push(
                  context,
                  AppRouter.slideFade(ProductListScreen(
                    appState: widget.appState,
                    searchQuery: controller.text,
                  )),
                );
              },
            ));

            if (products_list.isEmpty) {
              items.add(
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Text('💡', style: TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'NO EXACT MATCHES',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textHeading,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for something else',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }

          items.addAll(products_list.map((p) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                        ? AppImage(
                            url: p.imageUrl!,
                            fit: BoxFit.cover,
                            fallbackEmoji: p.emoji,
                          )
                        : Center(
                            child: Text(p.emoji,
                                style: const TextStyle(fontSize: 24))),
                  ),
                ),
                title: Text(
                  p.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textHeading,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '₨${p.price.toInt()} · ${p.category}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                trailing: Icon(Icons.north_west_rounded,
                    size: 18, color: AppTheme.textMuted.withOpacity(0.5)),
                onTap: () {
                  controller.closeView(p.name);
                  Navigator.push(
                    context,
                    AppRouter.slideFade(ProductListScreen(
                      appState: widget.appState,
                      searchQuery: p.name,
                    )),
                  );
                },
              )));

          return items;
        },
      ),
    );
  }

  Widget _buildDeals(DataProvider dataProvider) {
    final bundles = widget.appState.activeDeals;

    if (bundles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXCLUSIVE DEALS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 2.0,
                ),
              ),
              if (bundles.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${bundles.length} BUNDLES ACTIVE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accent,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: bundles.length,
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: (i) => setState(() => _dealIndex = i),
            itemBuilder: (_, i) {
              final item = bundles[i];
              return _PromotionBanner(
                deal: item,
                onTap: () => Navigator.push(
                  context,
                  AppRouter.slideFade(
                      DealDetailScreen(deal: item, appState: widget.appState)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bundles.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _dealIndex == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _dealIndex == i
                    ? AppTheme.primary
                    : AppTheme.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
                boxShadow: _dealIndex == i
                    ? [BoxShadow(color: AppTheme.primary, blurRadius: 4)]
                    : [],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(DataProvider dataProvider) {
    final categories = dataProvider.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORIES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 2.0,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  AppRouter.slideFade(
                      CategoriesScreen(appState: widget.appState)),
                ),
                child: Text(
                  'VIEW ALL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                // All Category
                final isSelected = _selectedCategoryName == null;
                return _CategoryItem(
                  category: const Category(
                    id: 'all',
                    name: 'All',
                    emoji: '🛍️',
                    color: 0xFFE0F2F1,
                  ),
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedCategoryName = null),
                );
              }

              final cat = categories[i - 1];
              final isSelected = _selectedCategoryName == cat.name;
              return _CategoryItem(
                category: cat,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCategoryName = cat.name),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopular(List<Product> popular) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 20, 20),
          child: Text(
            'TRENDING NOW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 2.0,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: popular.length,
          itemBuilder: (_, i) => ProductCard(
            product: popular[i],
            appState: widget.appState,
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color:
                    Color(category.color).withOpacity(isSelected ? 0.3 : 0.15),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppTheme.primary, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Color(category.color).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child:
                    category.imageUrl != null && category.imageUrl!.isNotEmpty
                        ? AppImage(
                            url: category.imageUrl!,
                            fit: BoxFit.cover,
                            fallbackEmoji: category.emoji,
                            borderRadius: 35,
                          )
                        : Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category.name.toUpperCase(),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                color: isSelected ? AppTheme.primary : AppTheme.textHeading,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  final Promotion? promotion;
  final dm.Deal? deal;
  final VoidCallback onTap;

  const _PromotionBanner({this.promotion, this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        promotion != null ? Color(promotion!.backgroundColor) : AppTheme.accent;

    final title = promotion?.title ?? deal?.name ?? '';
    final subtitle = promotion?.subtitle ??
        (deal != null ? '${deal!.items.length} Products included' : '');
    final tag = promotion?.tag ??
        (deal != null ? '${deal!.savingsPercentage}% OFF' : '');
    final imageUrl = promotion?.imageUrl ?? deal?.imageUrl;
    final emoji = promotion?.emoji ?? '🎁';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: bgColor.withOpacity(0.2),
          border: Border.all(color: bgColor.withOpacity(0.4), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background pattern or glow
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [bgColor.withOpacity(0.4), Colors.transparent],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: imageUrl != null
                              ? (promotion != null
                                  ? Image.asset(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                        child: Text(emoji,
                                            style:
                                                const TextStyle(fontSize: 40)),
                                      ),
                                    )
                                  : Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                        child: Text(emoji,
                                            style:
                                                const TextStyle(fontSize: 40)),
                                      ),
                                    ))
                              : Center(
                                  child: Text(emoji,
                                      style: const TextStyle(fontSize: 40)),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

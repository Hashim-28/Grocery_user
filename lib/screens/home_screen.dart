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
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  int _dealIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    showSearch(
      context: context,
      delegate: ProductSearchDelegate(appState: widget.appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final popular = AppData.products.where((p) => p.isBestSeller).toList();

    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.scaffold,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.1), 300),
          ),
          Positioned(
            top: 400,
            right: -150,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.08), 400),
          ),
          
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(child: _buildDeals()),
                SliverToBoxAdapter(child: _buildCategories()),
                SliverToBoxAdapter(child: _buildPopular(popular)),
                const SliverPadding(padding: EdgeInsets.only(bottom: 120)), // Space for bottom nav
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
                    Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 14),
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
                    AppRouter.slideFade(LocationPickerScreen(appState: widget.appState)),
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
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary, size: 22),
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
              child: Icon(Icons.notifications_none_rounded, color: AppTheme.textHeading, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _search,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search for fresh groceries...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
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
                child: const Icon(Icons.tune_rounded, color: Colors.black, size: 18),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 20, 20),
          child: Text(
            'EXCLUSIVE DEALS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 2.0,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: AppData.deals.length,
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: (i) => setState(() => _dealIndex = i),
            itemBuilder: (_, i) {
              final deal = AppData.deals[i];
              return _DealBanner(
                deal: deal,
                onTap: () => Navigator.push(
                  context,
                  AppRouter.slideFade(ProductListScreen(
                    appState: widget.appState,
                    categoryName: deal.targetCategory == 'All' ? null : deal.targetCategory,
                    showOnlyDiscounted: deal.title.contains('Sale') || deal.title.contains('Deal'),
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            AppData.deals.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _dealIndex == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _dealIndex == i ? AppTheme.primary : AppTheme.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
                boxShadow: _dealIndex == i ? [BoxShadow(color: AppTheme.primary, blurRadius: 4)] : [],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
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
                  AppRouter.slideFade(CategoriesScreen(appState: widget.appState)),
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
            itemCount: AppData.categories.length,
            itemBuilder: (_, i) {
              final cat = AppData.categories[i];
              return _CategoryItem(
                category: cat,
                onTap: () => Navigator.push(
                  context,
                  AppRouter.slideFade(ProductListScreen(
                    appState: widget.appState,
                    categoryName: cat.name,
                  )),
                ),
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
  final VoidCallback onTap;

  const _CategoryItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Color(category.color).withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(category.color).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AppImage(
                url: category.imageUrl,
                fit: BoxFit.cover,
                fallbackEmoji: category.emoji,
                borderRadius: 35,
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
                fontWeight: FontWeight.w800,
                color: AppTheme.textHeading,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealBanner extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;

  const _DealBanner({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(deal.backgroundColor);
    
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              deal.tag.toUpperCase(),
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
                              deal.title,
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
                            deal.subtitle,
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
                          child: deal.imageUrl != null
                              ? Image.asset(
                                  deal.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(deal.emoji, style: const TextStyle(fontSize: 40)),
                                  ),
                                )
                              : Center(
                                  child: Text(deal.emoji, style: const TextStyle(fontSize: 40)),
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


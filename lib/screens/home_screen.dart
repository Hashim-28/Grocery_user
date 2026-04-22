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
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        final displayProducts = popular.isEmpty ? products : popular;

        return ListenableBuilder(
          listenable: widget.appState,
          builder: (context, _) {
            return Scaffold(
              backgroundColor:
                  widget.appState.isDarkMode ? AppTheme.scaffold : Colors.white,
              body: Stack(
            children: [
              // Background Glows
              Positioned(
                top: -100.h,
                left: -100.w,
                child: widget.appState.isDarkMode
                    ? _buildBackgroundGlow(
                        AppTheme.primary.withOpacity(0.1), 300.r)
                    : const SizedBox.shrink(),
              ),
              Positioned(
                top: 400.h,
                right: -150.w,
                child: widget.appState.isDarkMode
                    ? _buildBackgroundGlow(
                        AppTheme.accent.withOpacity(0.1), 400.r)
                    : const SizedBox.shrink(),
              ),

              SafeArea(
                bottom: false,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(
                          child: _buildSearchBar(dataProvider.products)),
                      SliverToBoxAdapter(child: _buildDeals(dataProvider)),
                      SliverToBoxAdapter(child: _buildCategories(dataProvider)),
                      if (dataProvider.isLoading)
                        SliverFillRemaining(
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
                                  color: AppTheme.textMuted,
                                  fontSize: 14.sp),
                            ),
                          ),
                        )
                      else
                        SliverToBoxAdapter(child: _buildPopular(displayProducts)),
                      SliverPadding(
                          padding: EdgeInsets.only(
                              bottom: 120.h)), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
            );
          },
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
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
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
                        color: AppTheme.primary, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'DELIVERING TO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
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
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textHeading,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.primary, size: 22.sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              AppRouter.slideFade(NotificationsScreen(appState: widget.appState)),
            ),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppTheme.glassBorder, width: 1),
              ),
              child: Icon(Icons.notifications_none_rounded,
                  color: AppTheme.textHeading, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(List<Product> products) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SearchAnchor(
        viewBackgroundColor:
            widget.appState.isDarkMode ? AppTheme.scaffold : Colors.white,
        builder: (context, controller) {
          return GestureDetector(
            onTap: () => controller.openView(),
            child: Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: widget.appState.isDarkMode
                    ? AppTheme.surfaceVariant.withOpacity(0.8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
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
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: AppTheme.primary,
                      size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      controller.text.isEmpty
                          ? 'Search for fresh groceries...'
                          : controller.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: controller.text.isEmpty
                            ? AppTheme.textMuted
                            : AppTheme.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: AppTheme.neonShadow,
                    ),
                    child: Icon(Icons.tune_rounded,
                        color: Colors.white, size: 18.sp),
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
            items.add(ListTile(
              leading: Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(Icons.search_rounded, color: AppTheme.primary, size: 24.sp),
              ),
              title: Text(
                'Search for "${controller.text}"',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  fontSize: 16.sp,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.sp, color: AppTheme.primary),
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
                  padding: EdgeInsets.all(40.r),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Text('💡', style: TextStyle(fontSize: 40.sp)),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'NO EXACT MATCHES',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textHeading,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Try searching for something else',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textMuted, fontSize: 13.sp),
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
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                leading: Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                        ? AppImage(
                            url: p.imageUrl!,
                            fit: BoxFit.cover,
                            fallbackEmoji: p.emoji,
                          )
                        : Center(
                            child: Text(p.emoji,
                                style: TextStyle(fontSize: 24.sp))),
                  ),
                ),
                title: Text(
                  p.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textHeading,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  '₨${p.price.toInt()} · ${p.category}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                trailing: Icon(Icons.north_west_rounded,
                    size: 18.sp, color: AppTheme.textMuted.withOpacity(0.5)),
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
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 20.w, 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXCLUSIVE DEALS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 2.0,
                ),
              ),
              if (bundles.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${bundles.length} BUNDLES ACTIVE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.sp,
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
          height: 180.h,
          child: PageView.builder(
            itemCount: bundles.length,
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: (i) => setState(() => _dealIndex = i),
            itemBuilder: (_, i) {
              final item = bundles[i];
              return _PromotionBanner(
                deal: item,
                index: i,
                onTap: () => Navigator.push(
                  context,
                  AppRouter.slideFade(
                      DealDetailScreen(deal: item, appState: widget.appState)),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bundles.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _dealIndex == i ? 16.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _dealIndex == i
                    ? AppTheme.primary
                    : AppTheme.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3.r),
                boxShadow: _dealIndex == i
                    ? [BoxShadow(color: AppTheme.primary, blurRadius: 4.r)]
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
          padding: EdgeInsets.fromLTRB(24.w, 40.h, 20.w, 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORIES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
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
                    fontSize: 11.sp,
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
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: categories.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
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
          padding: EdgeInsets.fromLTRB(24.w, 40.h, 20.w, 20.h),
          child: Text(
            'TRENDING NOW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 2.0,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive crossAxisCount: 2 on mobile, more on wider screens
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: popular.length,
              itemBuilder: (_, i) => ProductCard(
                product: popular[i],
                appState: widget.appState,
              ),
            );
          },
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
        width: 80.w,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.only(top: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color:
                    Color(category.color).withOpacity(isSelected ? 0.3 : 0.15),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppTheme.primary, width: 2.w)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Color(category.color).withOpacity(0.1),
                    blurRadius: 10.r,
                    spreadRadius: 2.r,
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
                            borderRadius: 35.r,
                          )
                        : Text(
                            category.emoji,
                            style: TextStyle(fontSize: 30.sp),
                          ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              category.name.toUpperCase(),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
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
  final int index;
  final VoidCallback onTap;

  const _PromotionBanner({this.promotion, this.deal, required this.index, required this.onTap});

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
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          image: DecorationImage(
            image: AssetImage(index % 2 == 0 ? 'assets/images/b1.png' : 'assets/images/b2.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
          border: Border.all(color: bgColor.withOpacity(0.4), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Stack(
            children: [
              Positioned(
                right: -40.w,
                top: -40.h,
                child: Container(
                  width: 150.r,
                  height: 150.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [bgColor.withOpacity(0.4), Colors.transparent],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tag.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          SizedBox(height: 8.h),
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                      child: Center(
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Hero(
                                tag: 'banner-${deal?.id ?? promotion?.id}',
                                child: AppImage(
                                  url: imageUrl,
                                  fit: BoxFit.contain,
                                  fallbackEmoji: emoji,
                                  width: 70.w,
                                ),
                              )
                            : Text(emoji,
                                style: TextStyle(fontSize: 48.sp)),
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

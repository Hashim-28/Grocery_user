import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../widgets/global_cart_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class MainNavigation extends StatefulWidget {
  final AppState appState;
  final int initialIndex;

  const MainNavigation({
    super.key,
    required this.appState,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      HomeScreen(appState: widget.appState),
      CategoriesScreen(appState: widget.appState),
      CartScreen(appState: widget.appState),
      OrdersScreen(appState: widget.appState),
      ProfileScreen(appState: widget.appState),
    ];
  }

  void _goToCart() => setState(() => _currentIndex = 2);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (_, __) {
        AppTheme.isDarkMode = widget.appState.isDarkMode;
        
        final cartCount = widget.appState.totalCartCount;
        return Scaffold(
          extendBody: true, 
          backgroundColor: AppTheme.scaffold,
          body: Stack(
            children: [
              IndexedStack(index: _currentIndex, children: _screens),
              if (_currentIndex != 2) // Don't show on Cart tab itself
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 100.h, // Above the bottom nav
                  child: GlobalCartBar(
                    appState: widget.appState,
                    onTap: _goToCart,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(cartCount),
        );
      },
    );
  }

  Widget _buildBottomNav(int cartCount) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      height: 76.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: AppTheme.glassBorder, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, icon: Icons.home_rounded, label: 'Home', currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(index: 1, icon: Icons.grid_view_rounded, label: 'Categories', currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _CartNavItem(cartCount: cartCount, isSelected: _currentIndex == 2, onTap: _goToCart),
                _NavItem(index: 3, icon: Icons.receipt_long_rounded, label: 'Orders', currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(index: 4, icon: Icons.person_rounded, label: 'Profile', currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                size: 26.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                letterSpacing: 0.2,
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 4.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary, blurRadius: 4.r, spreadRadius: 1.r),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final int cartCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _CartNavItem({
    required this.cartCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Cart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    width: 4.r,
                    height: 4.r,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary, blurRadius: 4.r, spreadRadius: 1.r),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (cartCount > 0)
            Positioned(
              top: 5.h,
              right: 6.w,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.error, blurRadius: 6.r, spreadRadius: 1.r),
                  ],
                ),
                constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                child: Center(
                  child: Text(
                    cartCount > 9 ? '9+' : '$cartCount',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

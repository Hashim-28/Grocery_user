import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/models/category_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../data/app_data.dart';
import 'product_list_screen.dart';
import '../../widgets/cart_bar.dart';
import '../../widgets/core/app_widgets.dart';
import 'main_navigation.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class CategoriesScreen extends StatelessWidget {
  final AppState appState;
  const CategoriesScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'CATEGORIES',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                top: 200.h,
                right: -100.w,
                child: _buildBackgroundGlow(
                    AppTheme.primary.withOpacity(0.05), 300.r),
              ),

              Consumer<DataProvider>(
                builder: (context, dataProvider, _) {
                  if (dataProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = dataProvider.categories;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: 0.85,
                          mainAxisSpacing: 16.r,
                          crossAxisSpacing: 16.r,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (_, i) {
                          final cat = categories[i];
                          return _CategoryCard(
                            cat: cat,
                            appState: appState,
                            itemCount: dataProvider.products
                                .where((p) => p.category == cat.name)
                                .length,
                          );
                        },
                      );
                    },
                  );
                },
              ),

              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 100.h,
                child: CartBar(
                  appState: appState,
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    AppRouter.fade(
                        MainNavigation(appState: appState, initialIndex: 2)),
                    (r) => false,
                  ),
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
}

class _CategoryCard extends StatelessWidget {
  final Category cat;
  final AppState appState;
  final int itemCount;

  const _CategoryCard(
      {required this.cat, required this.appState, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final catColor = Color(cat.color);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppRouter.slideFade(ProductListScreen(
          appState: appState,
          categoryName: cat.name,
        )),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: catColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: catColor.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: catColor.withOpacity(0.2), blurRadius: 15.r),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: AppImage(
                  url: cat.imageUrl,
                  fit: BoxFit.cover,
                  fallbackEmoji: cat.emoji,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              cat.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.textHeading,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$itemCount ITEMS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

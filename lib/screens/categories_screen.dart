import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../data/app_data.dart';
import 'product_list_screen.dart';
import '../../widgets/cart_bar.dart';
import '../../widgets/core/app_widgets.dart';
import 'main_navigation.dart';
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
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ),
          body: Stack(
            children: [
              // Background Glows
              Positioned(
                top: 200,
                right: -100,
                child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.05), 300),
              ),
              
              GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: AppData.categories.length,
                itemBuilder: (_, i) {
                  final cat = AppData.categories[i];
                  return _CategoryCard(cat: cat, appState: appState);
                },
              ),
              
              Positioned(
                left: 20,
                right: 20,
                bottom: 100,
                child: CartBar(
                  appState: appState,
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    AppRouter.fade(MainNavigation(appState: appState, initialIndex: 2)),
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
  final dynamic cat;
  final AppState appState;

  const _CategoryCard({required this.cat, required this.appState});

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
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: catColor.withOpacity(0.2), blurRadius: 15),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: AppImage(
                  url: cat.imageUrl,
                  fit: BoxFit.cover,
                  fallbackEmoji: cat.emoji,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              cat.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textHeading,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${AppData.products.where((p) => p.category == cat.name).length} ITEMS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
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


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../data/app_data.dart';
import 'product_list_screen.dart';
import '../widgets/cart_bar.dart';

class CategoriesScreen extends StatelessWidget {
  final AppState appState;
  const CategoriesScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final categories = AppData.categories;
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 100,
                backgroundColor: AppTheme.primaryGreen,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'All Categories',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  background: Container(
                    decoration:
                        const BoxDecoration(gradient: AppTheme.primaryGradient),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final cat = categories[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListScreen(
                              appState: appState,
                              categoryName: cat['name'],
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(cat['color']),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Hero(
                            tag: 'category-${cat['name']}',
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: cat['image'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: cat['image'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.1)),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                          child: Text(
                                            cat['emoji'],
                                            style: const TextStyle(fontSize: 32),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          cat['emoji'],
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                              const SizedBox(height: 12),
                              Text(
                                cat['name'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _productCount(cat['name']),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
            ],
          ),
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) => Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartBar(appState: appState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCount(String cat) {
    final count = AppData.products.where((p) => p.category == cat).length;
    return Text(
      '$count items',
      style: GoogleFonts.outfit(
        fontSize: 11,
        color: AppTheme.textMedium,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

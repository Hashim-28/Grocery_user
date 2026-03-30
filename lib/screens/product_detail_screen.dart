import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import 'main_navigation.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final AppState appState;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          // Header with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: Container(
                  color: AppTheme.accentGreen,
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              product.emoji,
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 100),
                          ),
                        ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.weight} · ${product.category}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (product.stock < 20)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.orangeAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Low Stock: ${product.stock}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.orangeAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        '₨${product.price.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (product.originalPrice != null)
                        Text(
                          '₨${product.originalPrice!.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.accentGreen),
                  const SizedBox(height: 24),
                  Text(
                    'Product Description',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: AppTheme.textMedium,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Delivery Info
                  _infoTile(Icons.delivery_dining_rounded, 'Delivery speed',
                      'Gets delivered in 45-60 mins'),
                  const SizedBox(height: 16),
                  _infoTile(Icons.verified_user_rounded, 'Quality Guarantee',
                      '100% fresh or money back'),
                  const SizedBox(height: 120), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            Text(subtitle,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppTheme.textLight)),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: appState,
        builder: (_, __) {
          final qty = appState.getCartQuantity(product.id);
          return Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => appState.decreaseQuantity(product.id),
                      icon: const Icon(Icons.remove_rounded,
                          color: AppTheme.primaryGreen),
                    ),
                    Text(
                      '$qty',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    IconButton(
                      onPressed: () => appState.addToCart(product),
                      icon: const Icon(Icons.add_rounded,
                          color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart button
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (qty == 0) {
                        appState.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MainNavigation(
                                      appState: appState,
                                      initialIndex: 2,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainNavigation(
                              appState: appState,
                              initialIndex: 2,
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      qty == 0 ? 'Add to Cart' : 'Item in Cart',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

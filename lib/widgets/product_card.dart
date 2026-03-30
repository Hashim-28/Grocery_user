import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final AppState appState;
  final bool showQuantityControl;

  const ProductCard({
    super.key,
    required this.product,
    required this.appState,
    this.showQuantityControl = true,
  });

  @override
  Widget build(BuildContext context) {
    int qty = appState.getCartQuantity(product.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                appState: appState,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Area
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: product.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.brandGreen.withOpacity(0.3),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Center(child: Text(product.emoji, style: const TextStyle(fontSize: 44))),
                              )
                            : Text(product.emoji, style: const TextStyle(fontSize: 50)),
                      ),
                    ),
                  ),
                ),
                // Info Area
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '₨${product.price.toInt()}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.brandGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (showQuantityControl && qty > 0)
                              _qtyController()
                            else
                              _addButton(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _addButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        appState.addToCart(product);
        Feedback.forTap(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.brandGreen,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Add',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _qtyController() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => appState.decreaseQuantity(product.id),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.remove, size: 14, color: AppTheme.textDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '${appState.getCartQuantity(product.id)}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: () => appState.addToCart(product),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.brandGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

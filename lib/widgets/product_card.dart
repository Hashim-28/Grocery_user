import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/core/app_widgets.dart';
import 'dart:ui';

class ProductCard extends StatefulWidget {
  final Product product;
  final AppState appState;

  const ProductCard({
    super.key,
    required this.product,
    required this.appState,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _addController;
  late Animation<double> _addScale;

  @override
  void initState() {
    super.initState();
    _addController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _addScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _addController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _animateAdd() {
    _addController.forward().then((_) => _addController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (_, __) {
        final qty = widget.appState.getCartQuantity(widget.product.id);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: widget.product,
                appState: widget.appState,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: AppTheme.glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 11,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Hero(
                            tag: 'product-${widget.product.id}',
                            child: AppImage(
                              url: widget.product.imageUrl,
                              fit: BoxFit.cover,
                              fallbackEmoji: widget.product.emoji,
                              borderRadius: AppTheme.radiusL,
                              width: 100,
                            ),
                          ),
                        ),
                      ),
                      if (widget.product.hasDiscount)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: AppTheme.error.withOpacity(0.4), blurRadius: 8),
                              ],
                            ),
                            child: Text(
                              '-${widget.product.discountPercent}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info Section
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textHeading,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.product.weight,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '₨${widget.product.price.toInt()}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                  if (widget.product.hasDiscount)
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '₨${widget.product.originalPrice!.toInt()}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: AppTheme.textMuted,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (qty > 0)
                              _QtyControl(
                                qty: qty,
                                onAdd: () {
                                  _animateAdd();
                                  widget.appState.addToCart(widget.product);
                                },
                                onRemove: () => widget.appState.decreaseQuantity(widget.product.id),
                              )
                            else
                              ScaleTransition(
                                scale: _addScale,
                                child: GestureDetector(
                                  onTap: () {
                                    _animateAdd();
                                    widget.appState.addToCart(widget.product);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: AppTheme.neonShadow,
                                    ),
                                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
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
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QtyControl({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.remove_rounded, size: 14, color: AppTheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$qty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppTheme.textHeading,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


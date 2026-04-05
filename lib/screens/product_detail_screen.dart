import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../models/models.dart';
import '../../widgets/core/app_widgets.dart';
import '../../widgets/cart_bar.dart';
import 'main_navigation.dart';
import 'dart:ui';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final AppState appState;

  const ProductDetailScreen({super.key, required this.product, required this.appState});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    final cartQty = widget.appState.getCartQuantity(widget.product.id);
    if (cartQty > 0) _qty = cartQty;
  }

  void _add() => setState(() => _qty++);
  void _remove() {
    if (_qty > 1) setState(() => _qty--);
  }

  void _addToCart() {
    final currentInCart = widget.appState.getCartQuantity(widget.product.id);
    if (currentInCart == 0) {
      for (int i = 0; i < _qty; i++) {
        widget.appState.addToCart(widget.product);
      }
    } else {
      widget.appState.removeFromCart(widget.product.id);
      for (int i = 0; i < _qty; i++) {
        widget.appState.addToCart(widget.product);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.neonShadow,
          ),
          child: Text(
            '${widget.product.name} added to cart',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 200,
            left: -100,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.08), 300),
          ),
          Positioned(
            bottom: 300,
            right: -150,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.06), 400),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent, // Fix: Use transparent to see the rich background
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: AppTheme.textHeading,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Smooth Background Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primary.withOpacity(0.15),
                              AppTheme.scaffold,
                            ],
                          ),
                        ),
                      ),
                      // Large Ambient Glow
                      Positioned(
                        top: -50,
                        right: -50,
                        child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.1), 300),
                      ),
                      // Condition for Rice to cover all background
                      if (widget.product.id == 'p5')
                        Positioned.fill(
                          child: Hero(
                            tag: 'product-${widget.product.id}',
                            child: AppImage(
                              url: widget.product.imageUrl,
                              fit: BoxFit.cover,
                              fallbackEmoji: widget.product.emoji,
                            ),
                          ),
                        )
                      else ...[
                        // Main Product Glow
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.3, 1.0],
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'product-${widget.product.id}',
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: AppImage(
                              url: widget.product.imageUrl,
                              fit: BoxFit.contain,
                              fallbackEmoji: widget.product.emoji,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.favorite_border_rounded, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.6), // Fix: More solid "full colored" look
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    border: Border.all(color: AppTheme.glassBorder, width: 1.5),
                  ),
                  transform: Matrix4.translationValues(0, 0, 0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 150), // Fix: Sweeter padding (24 instead of 36)
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add a small handler to make the sheet look intentional
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: AppTheme.textMuted.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.textHeading,
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            widget.product.category.toUpperCase(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.primary,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          widget.product.weight,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '₨${widget.product.price.toInt()}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primary,
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                    ),
                                    if (widget.product.hasDiscount)
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₨${widget.product.originalPrice!.toInt()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: AppTheme.textMuted,
                                            decoration: TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Divider(color: AppTheme.glassBorder),
                          const SizedBox(height: 32),
                          Text(
                            'DESCRIPTION',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMuted,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              height: 1.8,
                              color: AppTheme.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.glassBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.flash_on_rounded, color: AppTheme.primary, size: 18),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Get it delivered within 60 minutes via Diesel Fast.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppTheme.textHeading,
                                      fontWeight: FontWeight.w600,
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
                  ),
                ),
              ),
            ],
          ),
          
          CartBar(
            appState: widget.appState,
            bottom: 120,
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              AppRouter.fade(MainNavigation(appState: widget.appState, initialIndex: 2)),
              (r) => false,
            ),
          ),
          
          // Bottom Action Bar - Floating Glassmorphic
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.glassBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _remove,
                              icon: Icon(Icons.remove_rounded, color: AppTheme.textMuted),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            Text(
                              '$_qty',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textHeading,
                              ),
                            ),
                            IconButton(
                              onPressed: _add,
                              icon: Icon(Icons.add_rounded, color: AppTheme.primary),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _addToCart,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: AppTheme.neonShadow,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_basket_rounded, color: Colors.black, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'ADD TO CART',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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


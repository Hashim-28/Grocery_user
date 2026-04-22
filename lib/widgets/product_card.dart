import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/core/app_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
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

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: ConstraintLayout(
              children: [
                // Image Background & Image
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: AppImage(
                        url: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        fallbackEmoji: widget.product.emoji,
                        borderRadius: AppTheme.radiusL,
                        width: 80.w, // Scaled width
                      ),
                    ),
                  ),
                ).applyConstraint(
                  id: ConstraintId('image_bg'),
                  width: matchConstraint,
                  height: matchConstraint,
                  top: parent.top,
                  left: parent.left,
                  right: parent.right,
                  bottom: ConstraintId('info_section').top,
                  margin: EdgeInsets.all(8.r),
                ),

                // Discount Badge
                if (widget.product.hasDiscount)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '-${widget.product.discountPercent}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ).applyConstraint(
                    id: ConstraintId('discount'),
                    top: ConstraintId('image_bg').top,
                    left: ConstraintId('image_bg').left,
                    margin: EdgeInsets.all(8.r),
                  ),

                // Info Section (Title, Weight, Price, Action)
                ConstraintLayout(
                  children: [
                    // Product Name
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textHeading,
                        letterSpacing: -0.2,
                      ),
                    ).applyConstraint(
                      id: ConstraintId('name'),
                      top: parent.top,
                      left: parent.left,
                      right: parent.right,
                      width: matchConstraint,
                    ),

                    // Weight
                    Text(
                      widget.product.weight,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ).applyConstraint(
                      id: ConstraintId('weight'),
                      top: ConstraintId('name').bottom,
                      left: parent.left,
                      margin: EdgeInsets.only(top: 2.h),
                    ),

                    // Price
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₨${widget.product.price.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ).applyConstraint(
                      id: ConstraintId('price'),
                      bottom: parent.bottom,
                      left: parent.left,
                      right: ConstraintId('action').left,
                      horizontalBias: 0,
                    ),

                    // Original Price
                    if (widget.product.hasDiscount)
                      Text(
                        '₨${widget.product.originalPrice!.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          color: AppTheme.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ).applyConstraint(
                        id: ConstraintId('old_price'),
                        bottom: ConstraintId('price').top,
                        left: parent.left,
                      ),

                    // Action Button (Qty or Add)
                    (qty > 0
                            ? _QtyControl(
                                qty: qty,
                                onAdd: () {
                                  _animateAdd();
                                  widget.appState.addToCart(widget.product);
                                },
                                onRemove: () => widget.appState
                                    .decreaseQuantity(widget.product.id),
                              )
                            : ScaleTransition(
                                scale: _addScale,
                                child: GestureDetector(
                                  onTap: () {
                                    _animateAdd();
                                    widget.appState.addToCart(widget.product);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: AppTheme.neonShadow,
                                    ),
                                    child: Icon(Icons.add_rounded,
                                        color: Colors.white, size: 20.r),
                                  ),
                                ),
                              ))
                        .applyConstraint(
                      id: ConstraintId('action'),
                      bottom: parent.bottom,
                      right: parent.right,
                    ),
                  ],
                ).applyConstraint(
                  id: ConstraintId('info_section'),
                  width: matchConstraint,
                  height: wrapContent,
                  bottom: parent.bottom,
                  left: parent.left,
                  right: parent.right,
                  margin: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
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

  const _QtyControl(
      {required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.remove_rounded,
                  size: 14.sp, color: AppTheme.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '$qty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.textHeading,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.add_rounded, size: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

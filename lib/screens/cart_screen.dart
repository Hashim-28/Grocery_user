import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import 'checkout_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class CartScreen extends StatelessWidget {
  final AppState appState;
  const CartScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (_, __) {
        final items = appState.cartItems;
        final isEmpty = items.isEmpty;

        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'REVIEW ORDER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
            actions: [
              if (!isEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context),
                  child: Text(
                    'CLEAR',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              SizedBox(width: 8.w),
            ],
          ),
          body: Stack(
            children: [
              // Background Glow
              Positioned(
                top: 100.h,
                left: -100.w,
                child: _buildBackgroundGlow(AppTheme.primary.withOpacity(AppTheme.isDarkMode ? 0.05 : 0.02), 300.r),
              ),
              
              isEmpty
                  ? _buildEmpty()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => SizedBox(height: 16.h),
                            itemBuilder: (_, i) => _CartItemTile(
                              item: items[i],
                              appState: appState,
                            ),
                          ),
                        ),
                        _buildSummary(appState, context),
                      ],
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

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.surface.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: AppTheme.glassBorder),
          ),
          title: Text(
            'Clear Cart?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: AppTheme.textHeading, fontSize: 18.sp),
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart?',
            style: GoogleFonts.plusJakartaSans(color: AppTheme.textBody, fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontWeight: FontWeight.w800, fontSize: 13.sp)),
            ),
            TextButton(
              onPressed: () {
                appState.clearCart();
                Navigator.pop(ctx);
              },
              child: Text('CLEAR ALL', style: GoogleFonts.plusJakartaSans(color: AppTheme.error, fontWeight: FontWeight.w800, fontSize: 13.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart_checkout_rounded, color: AppTheme.primary, size: 40.sp),
          ),
          SizedBox(height: 32.h),
          Text(
            'YOUR CART IS EMPTY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: AppTheme.textHeading,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Looks like you haven\'t added any\nfresh groceries to your list yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(AppState appState, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.8),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SummaryRow(label: 'Order Subtotal', value: appState.cartSubtotal),
                  SizedBox(height: 12.h),
                  _SummaryRow(
                    label: 'Delivery Logistics',
                    value: appState.deliveryFee,
                    isFree: appState.deliveryFee == 0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Divider(color: AppTheme.glassBorder),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL PAYABLE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '₨${appState.cartTotal.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  AppButton(
                    label: 'PROCEED TO CHECKOUT',
                    onPressed: () => Navigator.push(
                      context,
                      AppRouter.slideFade(CheckoutScreen(appState: appState)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final AppState appState;

  const _CartItemTile({required this.item, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16.r),
            ),
            padding: EdgeInsets.all(10.r),
            child: item.isDeal && item.deal!.imageUrl != null
                ? Image.network(item.deal!.imageUrl!, fit: BoxFit.cover)
                : AppImage(
                    url: item.product?.imageUrl ?? item.deal?.imageUrl,
                    fit: BoxFit.contain,
                    fallbackEmoji: item.itemEmoji,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textHeading,
                  ),
                ),
                Text(
                  '${item.isDeal ? "Bundle Offer" : item.product!.weight} · ₨${item.price.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₨${item.total.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Row(
                        children: [
                          _btn(Icons.remove_rounded, () => appState.decreaseQuantity(item.id)),
                          SizedBox(
                            width: 32.w,
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.sp,
                                  color: AppTheme.textHeading,
                                ),
                              ),
                            ),
                          ),
                          _btn(Icons.add_rounded, 
                            () => item.isDeal ? appState.addDealToCart(item.deal!) : appState.addToCart(item.product!), 
                            color: AppTheme.primary
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {Color? color}) {
    final effectiveColor = color ?? AppTheme.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Icon(icon, size: 18.sp, color: effectiveColor),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isFree;

  const _SummaryRow({required this.label, required this.value, this.isFree = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textBody,
          ),
        ),
        Text(
          isFree ? 'FREE' : '₨${value.toInt()}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: isFree ? AppTheme.accent : AppTheme.textHeading,
          ),
        ),
      ],
    );
  }
}

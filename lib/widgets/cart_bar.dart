import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class CartBar extends StatefulWidget {
  final AppState appState;
  final VoidCallback onTap;
  final double bottom;

  const CartBar(
      {super.key,
      required this.appState,
      required this.onTap,
      this.bottom = 20});

  @override
  State<CartBar> createState() => _CartBarState();
}

class _CartBarState extends State<CartBar> {
  bool _isDismissed = false;
  int _lastCount = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (_, __) {
        final count = widget.appState.totalCartCount;

        // Reset dismissal if items are added
        if (count > _lastCount) {
          _isDismissed = false;
        }
        _lastCount = count;

        if (_isDismissed || count == 0) return const SizedBox.shrink();

        return Dismissible(
          key: const Key('cart-bar-dismiss'),
          direction: DismissDirection.down,
          onDismissed: (_) => setState(() => _isDismissed = true),
          child: GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: AppTheme.neonShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'VIEW YOUR CART',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.sp,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              widget.appState.cartItems.isNotEmpty 
                                ? '${widget.appState.totalCartCount} items in basket'
                                : '0 items',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₨${widget.appState.cartSubtotal.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18.sp,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 16.sp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../utils/app_router.dart';
import 'main_navigation.dart';
import '../utils/app_state.dart';
import '../widgets/core/app_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class OrderDeliveredScreen extends StatelessWidget {
  final Order order;
  final AppState appState;

  const OrderDeliveredScreen({super.key, required this.order, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: Stack(
        children: [
          Positioned(
            top: 100.h,
            left: -100.w,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.08), 300.r),
          ),
          Positioned(
            bottom: 100.h,
            right: -150.w,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.06), 400.r),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 140.r,
                    height: 140.r,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.2),
                          blurRadius: 40.r,
                          spreadRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primary,
                      size: 90.sp,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    'ORDER COMPLETED',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Your fresh supplies have been\nsafely delivered to your address.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      color: AppTheme.textBody,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(28.r),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(label: 'ORDER ID', value: '#${order.id}'),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Divider(color: AppTheme.glassBorder),
                            ),
                            _DetailRow(label: 'LOCATION NAME', value: order.deliveryAddress.split(',')[0].toUpperCase()),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Divider(color: AppTheme.glassBorder),
                            ),
                            _DetailRow(label: 'TOTAL AMOUNT', value: '₨${order.total.toInt()}', isBold: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'RETURN TO DASHBOARD',
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      AppRouter.fade(MainNavigation(appState: appState)),
                      (r) => false,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () {}, 
                    child: Text(
                      'RATE TRANSMISSION',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        fontSize: 12.sp,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textMuted,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppTheme.primary : AppTheme.textHeading,
          ),
        ),
      ],
    );
  }
}

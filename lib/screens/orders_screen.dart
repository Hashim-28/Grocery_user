import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../data/app_data.dart';
import 'order_tracking_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class OrdersScreen extends StatefulWidget {
  final AppState appState;
  const OrdersScreen({super.key, required this.appState});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (_, __) {
        final orders = widget.appState.orders;
        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'ORDER HISTORY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => widget.appState.fetchOrders(),
                icon: Icon(Icons.refresh_rounded, size: 24.sp),
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: Stack(
            children: [
              Positioned(
                top: 100.h,
                left: -100.w,
                child: _buildBackgroundGlow(
                    AppTheme.primary.withOpacity(0.05), 300.r),
              ),

              RefreshIndicator(
                onRefresh: () => widget.appState.fetchOrders(),
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                child: orders.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildInfoBanner(),
                            SizedBox(
                              height: 1.sh - 300.h,
                              child: _buildEmpty(),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                        itemCount: orders.length + 1,
                        separatorBuilder: (_, i) =>
                            SizedBox(height: i == 0 ? 12.h : 16.h),
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return _buildInfoBanner();
                          }
                          final order = orders[i - 1];
                          final statusData =
                              AppData.orderStatuses[order.statusIndex];

                          return _OrderHistoryCard(
                            order: order,
                            statusData: statusData,
                            appState: widget.appState,
                          );
                        },
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

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18.sp, color: AppTheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Showing order history for the last 30 days',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textHeading.withOpacity(0.8),
              ),
            ),
          ),
        ],
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
            child: Icon(Icons.receipt_long_rounded,
                size: 60.sp, color: AppTheme.primary),
          ),
          SizedBox(height: 32.h),
          Text(
            'NO TRANSMISSIONS YET',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: AppTheme.textHeading,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Your sequence logs will appear here\nonce you initiate an order.',
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
}

class _OrderHistoryCard extends StatelessWidget {
  final dynamic order;
  final Map<String, String> statusData;
  final AppState appState;

  const _OrderHistoryCard({
    required this.order,
    required this.statusData,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppRouter.slideFade(OrderTrackingScreen(
          order: order,
          appState: appState,
        )),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${order.orderId ?? order.id.substring(0, 6)}'
                          .toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        fontSize: 11.sp,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      order.date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(color: AppTheme.glassBorder),
                ),
                Row(
                  children: [
                    Container(
                      width: 54.r,
                      height: 54.r,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(statusData['icon']!,
                          style: TextStyle(fontSize: 22.sp)),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusData['title']!.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                              color: AppTheme.textHeading,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${order.itemCount} ITEMS · ₨${order.total.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14.sp, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

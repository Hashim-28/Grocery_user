import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/models.dart';
import '../../data/app_data.dart';
import 'order_delivered_screen.dart';
import '../../utils/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  final AppState appState;

  const OrderTrackingScreen(
      {super.key, required this.order, required this.appState});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'LIVE ORDER STATUS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              'TRACE ID: ${widget.order.orderId ?? widget.order.id.substring(0, 6)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => widget.appState.fetchOrders(),
            icon: Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 24.sp),
            tooltip: 'Refresh Status',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (_, __) {
          final statuses = AppData.orderStatuses;
          final currentStatus = widget.order.statusIndex;

          if (currentStatus == 4) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                AppRouter.fade(OrderDeliveredScreen(
                  order: widget.order,
                  appState: widget.appState,
                )),
              );
            });
          }

          return Stack(
            children: [
              Positioned(
                top: 200.h,
                right: -100.w,
                child: _buildBackgroundGlow(
                    AppTheme.primary.withOpacity(AppTheme.isDarkMode ? 0.05 : 0.02), 300.r),
              ),

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildEstTime()),
                  if (widget.order.paymentProofUrl != null)
                    SliverToBoxAdapter(child: _buildPaymentInfo()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 40.h),
                      child: Column(
                        children: List.generate(
                          statuses.length,
                          (i) => _buildStepperItem(statuses[i], i,
                              currentStatus, i == statuses.length - 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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

  Widget _buildEstTime() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: ClipRRect(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVERY TYPE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on_rounded,
                          color: AppTheme.primary, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        widget.order.deliverySpeed.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildStepperItem(
      Map<String, String> status, int index, int currentStatus, bool isLast) {
    final isDone = index < currentStatus;
    final isActive = index == currentStatus;

    Color stepColor = isDone || isActive
        ? AppTheme.primary
        : AppTheme.textMuted.withOpacity(0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isActive)
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.8).animate(_pulseCtrl),
                      child: Container(
                        width: 16.r,
                        height: 16.r,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppTheme.primary
                          : (isActive
                              ? AppTheme.scaffold
                              : AppTheme.surfaceVariant.withOpacity(0.3)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stepColor,
                        width: 2.w,
                      ),
                      boxShadow: isDone || isActive
                          ? [
                              BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 10.r),
                            ]
                          : [],
                    ),
                    child: isDone
                        ? Icon(Icons.check_rounded,
                            color: Colors.white, size: 16.sp)
                        : (isActive
                            ? Icon(Icons.sync_rounded,
                                color: AppTheme.primary, size: 16.sp)
                            : null),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          stepColor,
                          index + 1 <= currentStatus
                              ? AppTheme.primary
                              : AppTheme.textMuted.withOpacity(0.2),
                        ],
                      ),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
            ],
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 48.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status['title']!.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: isDone || isActive
                              ? AppTheme.textHeading
                              : AppTheme.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (isDone || isActive) _buildStatusTime(index),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    status['subtitle']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: AppTheme.textBody,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _viewProof(widget.order.paymentProofUrl!),
                  child: Container(
                    width: 60.r,
                    height: 60.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.primary, width: 2.w),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        widget.order.paymentProofUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYMENT VERIFIED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Online Transfer proof submitted',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textHeading,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: AppTheme.accent, size: 24.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewProof(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(url),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTime(int index) {
    DateTime? time;
    switch (index) {
      case 0:
        return Text(
          widget.order.date,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textMuted,
          ),
        );
      case 1:
        time = widget.order.confirmedAt;
        break;
      case 2:
        time = widget.order.packedAt;
        break;
      case 3:
        time = widget.order.outForDeliveryAt;
        break;
      case 4:
        time = widget.order.deliveredAt;
        break;
    }

    if (time == null) return const SizedBox.shrink();

    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    final minutes = time.minute.toString().padLeft(2, '0');

    return Text(
      '$hour:$minutes $amPm',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppTheme.textMuted,
      ),
    );
  }
}

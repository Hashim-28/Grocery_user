import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../data/app_data.dart';
import '../../models/models.dart';
import '../../widgets/core/app_widgets.dart';
import 'main_navigation.dart';
import 'order_tracking_screen.dart';
import 'profile/address_book_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/payment_account_model.dart';
import 'dart:ui';

class CheckoutScreen extends StatefulWidget {
  final AppState appState;
  const CheckoutScreen({super.key, required this.appState});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cod';
  String _deliverySpeed = 'Standard';
  bool _isLoading = false;

  void _handleOrderPlacement() {
    if (widget.appState.addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PLEASE ADD AN ADDRESS TO PLACE ORDER',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12.sp,
              letterSpacing: 1.0,
            ),
          ),
          action: SnackBarAction(
            label: 'ADD NODE',
            textColor: AppTheme.primary,
            onPressed: () {
              Navigator.push(
                context,
                AppRouter.slideFade(AddressBookScreen(appState: widget.appState)),
              );
            },
          ),
        ),
      );
      return;
    }

    if (_paymentMethod == 'cod') {
      _placeOrder();
    } else {
      final account = widget.appState.paymentAccounts.firstWhere((a) => a.id == _paymentMethod);
      _showOnlinePaymentDetails(account);
    }
  }

  void _showOnlinePaymentDetails(PaymentAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OnlinePaymentSheet(
        account: account,
        onScreenshotUploaded: (file) {
          Navigator.pop(context);
          _showFinalConfirmation(file, account.id);
        },
      ),
    );
  }

  void _showFinalConfirmation(File image, String accountId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(
          'CONFIRM ORDER',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16.sp),
        ),
        content: SizedBox(
          width: 320.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm your order with the uploaded payment screenshot?',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13.sp),
              ),
              SizedBox(height: 20.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(image, height: 180.h, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('RETRY', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.textMuted, fontSize: 13.sp)),
          ),
          AppButton(
            label: 'PLACE ORDER',
            onPressed: () {
              Navigator.pop(context);
              _placeOrder(proofFile: image, accountId: accountId);
            },
          ),
        ],
      ),
    );
  }

  void _placeOrder({File? proofFile, String? accountId}) async {
    setState(() => _isLoading = true);
    
    String? proofUrl;
    if (proofFile != null) {
      proofUrl = await widget.appState.uploadPaymentProof(proofFile);
    }

    await widget.appState.placeOrder(
      address: widget.appState.deliveryAddress,
      paymentMethod: _paymentMethod == 'cod' ? 'Cash on Delivery' : 'Online Bank Transfer',
      deliverySpeed: _deliverySpeed,
      paymentProofUrl: proofUrl,
      paymentAccountId: accountId,
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    final newOrder = widget.appState.orders.isNotEmpty ? widget.appState.orders.first : null;

    setState(() => _isLoading = false);
    if (newOrder != null) {
      _showOrderSuccess(newOrder);
    } else {
      Navigator.pop(context);
    }
  }

  void _showOrderSuccess(Order order) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(32.r),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20.r),
                  ],
                ),
                child: Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 48.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                'ORDER PLACED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textHeading,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your order #${order.id} is confirmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              AppButton(
                label: 'TRACK ORDER',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    AppRouter.slideFade(OrderTrackingScreen(
                      order: order,
                      appState: widget.appState,
                    )),
                    (r) => r.isFirst,
                  );
                },
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    AppRouter.fade(MainNavigation(appState: widget.appState)),
                    (r) => false,
                  );
                },
                child: Text(
                  'Back To Home',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMuted,
                    fontSize: 12.sp,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: Text(
          'CHECKOUT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100.h,
            left: -150.w,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.05), 400.r),
          ),
          Positioned(
            bottom: 200.h,
            right: -100.w,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.05), 300.r),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAddressSection()),
              SliverToBoxAdapter(child: _buildDeliverySpeed()),
              SliverToBoxAdapter(child: _buildPaymentMethods()),
              SliverToBoxAdapter(child: SizedBox(height: 140.h)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 16.h),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: AppTheme.textMuted,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('DELIVERY TARGET'),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADDRESS: HOME',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                        color: AppTheme.textHeading,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    ListenableBuilder(
                      listenable: widget.appState,
                      builder: (_, __) => Text(
                        widget.appState.deliveryAddress,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  AppRouter.slideFade(AddressBookScreen(appState: widget.appState)),
                ),
                icon: Icon(Icons.edit_road_rounded, color: AppTheme.primary, size: 20.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySpeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('LOGISTICS SPEED'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: _SpeedCard(
                  title: 'Standard',
                  subtitle: widget.appState.standardEta,
                  icon: Icons.local_shipping_outlined,
                  isSelected: _deliverySpeed == 'Standard',
                  onTap: () => setState(() => _deliverySpeed = 'Standard'),
                ),
              ),
              if (widget.appState.expressEnabled) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: _SpeedCard(
                    title: 'Express',
                    subtitle: widget.appState.expressEta,
                    icon: Icons.bolt_rounded,
                    fee: '+₨${widget.appState.expressCharge.toInt()}',
                    isSelected: _deliverySpeed == 'Express',
                    onTap: () => setState(() => _deliverySpeed = 'Express'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('TRANSACTION MODE'),
        ListenableBuilder(
          listenable: widget.appState,
          builder: (context, _) {
            final accounts = widget.appState.paymentAccounts;
            final items = [
              ...AppData.paymentMethods,
              ...accounts.map((acc) => {
                'id': acc.id,
                'name': acc.accountName,
                'subtitle': 'Bank Transfer to ${acc.holderName}',
                'icon': '🏦',
              }),
            ];

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final pm = items[i];
                final isSelected = _paymentMethod == pm['id'];
                return GestureDetector(
                  onTap: () => setState(() => _paymentMethod = pm['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.glassBorder,
                        width: 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 10.r)
                      ] : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceVariant.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(pm['icon']!, style: TextStyle(fontSize: 22.sp)),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pm['name']!.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.sp,
                                  color: isSelected ? AppTheme.primary : AppTheme.textHeading,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                pm['subtitle']!,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    double finalTotal = widget.appState.cartTotal;
    if (_deliverySpeed == 'Express') finalTotal += widget.appState.expressCharge;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 36.h),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.8),
            border: Border(top: BorderSide(color: AppTheme.glassBorder)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL PAYABLE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '₨${finalTotal.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 32.w),
                Expanded(
                  child: AppButton(
                    label: 'CONFIRM ORDER',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleOrderPlacement,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? fee;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.fee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.glassBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textMuted, size: 24.sp),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20.sp),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 13.sp,
                color: isSelected ? AppTheme.primary : AppTheme.textHeading,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (fee != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  fee!,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 10.sp,
                    color: isSelected ? Colors.black : AppTheme.textHeading,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OnlinePaymentSheet extends StatelessWidget {
  final PaymentAccount account;
  final Function(File) onScreenshotUploaded;

  const _OnlinePaymentSheet({required this.account, required this.onScreenshotUploaded});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: AppTheme.glassBorder, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'PAYMENT DETAILS',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 2.0),
            ),
            SizedBox(height: 24.h),
            _buildDetailRow('BANK NAME', account.accountName),
            _divider(),
            _buildDetailRow('ACCOUNT HOLDER', account.holderName),
            _divider(),
            _buildDetailRow('ACCOUNT NUMBER', account.accountNumber),
            if (account.iban != null && account.iban!.isNotEmpty) ...[
               _divider(),
              _buildDetailRow('IBAN', account.iban!),
            ],
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Please transfer the amount and upload the screenshot of the transaction here.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: AppTheme.textHeading, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            AppButton(
              label: 'UPLOAD SCREENSHOT',
              onPressed: () async {
                 final picker = ImagePicker();
                 final image = await picker.pickImage(source: ImageSource.gallery);
                 if (image != null) {
                   onScreenshotUploaded(File(image.path));
                 }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.0)),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textHeading))),
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 18.sp, color: AppTheme.primary),
              onPressed: () {
                // Clipboard integration could be added here
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _divider() => Padding(padding: EdgeInsets.symmetric(vertical: 12.h), child: Divider(color: AppTheme.glassBorder, height: 1));
}

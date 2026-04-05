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

  void _placeOrder() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    widget.appState.placeOrder(
      address: widget.appState.deliveryAddress,
      paymentMethod: _paymentMethod,
      deliverySpeed: _deliverySpeed,
    );

    final newOrder = widget.appState.orders.first;
    widget.appState.clearCart();

    setState(() => _isLoading = false);
    _showOrderSuccess(newOrder);
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
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20),
                  ],
                ),
                child: Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'ORDER PLACED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textHeading,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order #${order.id} is confirmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 12),
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
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 100,
            left: -150,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.05), 400),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.05), 300),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAddressSection()),
              SliverToBoxAdapter(child: _buildDeliverySpeed()),
              SliverToBoxAdapter(child: _buildPaymentMethods()),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
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
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADDRESS: HOME',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppTheme.textHeading,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ListenableBuilder(
                      listenable: widget.appState,
                      builder: (_, __) => Text(
                        widget.appState.deliveryAddress,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 13,
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
                icon: Icon(Icons.edit_road_rounded, color: AppTheme.primary, size: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _SpeedCard(
                  title: 'Standard',
                  subtitle: '2-3 hours',
                  icon: Icons.local_shipping_outlined,
                  isSelected: _deliverySpeed == 'Standard',
                  onTap: () => setState(() => _deliverySpeed = 'Standard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SpeedCard(
                  title: 'Express',
                  subtitle: '45 mins',
                  icon: Icons.bolt_rounded,
                  fee: '+₨100',
                  isSelected: _deliverySpeed == 'Express',
                  onTap: () => setState(() => _deliverySpeed = 'Express'),
                ),
              ),
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: AppData.paymentMethods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final pm = AppData.paymentMethods[i];
            final isSelected = _paymentMethod == pm['id'];
            return GestureDetector(
              onTap: () => setState(() => _paymentMethod = pm['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.glassBorder,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 10)
                  ] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceVariant.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(pm['icon']!, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pm['name']!.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: isSelected ? AppTheme.primary : AppTheme.textHeading,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pm['subtitle']!,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    double finalTotal = widget.appState.cartTotal;
    if (_deliverySpeed == 'Express') finalTotal += 100;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '₨${finalTotal.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: AppButton(
                    label: 'CONFIRM ORDER',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _placeOrder,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
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
                Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textMuted, size: 24),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: isSelected ? AppTheme.primary : AppTheme.textHeading,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (fee != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fee!,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
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


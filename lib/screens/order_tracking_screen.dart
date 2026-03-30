import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import 'order_delivered_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  final AppState appState;
  const OrderTrackingScreen({super.key, required this.order, required this.appState});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statuses = AppData.orderStatuses;
    final currentStatus = widget.order.statusIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Track Order',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Order ID: #${widget.order.id}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandGreen,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildArrivalHeader(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Order Status',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTrackingStepper(statuses, currentStatus),
                const SizedBox(height: 32),
                _buildOrderItems(),
              ],
            ),
          ),
          
          // Bottom Rider Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showRiderDetails(context),
              child: _buildRiderCard(),
            ),
          ),
          
          // Debug Auto-Advance
          if (currentStatus < 3)
            Positioned(
              top: 10,
              right: 16,
              child: _debugAdvanceButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildArrivalHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _arrivalInfoTile(Icons.access_time_filled_rounded, 'Arrival Time', '12:45 PM'),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              _arrivalInfoTile(Icons.location_on_rounded, 'Distance', '3.8 km'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.brandGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Our rider is on the way to pick up your order from Diesel Cash & Carry.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _arrivalInfoTile(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.brandGreen, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingStepper(List<Map<String, String>> statuses, int currentStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(statuses.length, (i) {
          final isDone = i < currentStatus;
          final isActive = i == currentStatus;
          final isLast = i == statuses.length - 1;

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
                            scale: Tween(begin: 1.0, end: 1.5).animate(_pulseCtrl),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.brandGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDone || isActive ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone || isActive ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                              : isActive
                                  ? const Icon(Icons.sync_rounded, color: Colors.white, size: 16)
                                  : null,
                        ),
                      ],
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isDone ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statuses[i]['title']!,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDone || isActive ? AppTheme.textDark : AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statuses[i]['subtitle']!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        if (isDone || isActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '12:${30 + (i * 5)} PM',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.brandGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Order Items',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: widget.order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(item.product.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '${item.quantity} x ₨${item.product.price.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRiderCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1976&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmed Ali',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Rider · Diesel Cash & Carry',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _circleAction(Icons.chat_bubble_rounded, AppTheme.brandGreen.withOpacity(0.1), AppTheme.brandGreen),
                  const SizedBox(width: 12),
                  _circleAction(Icons.call_rounded, AppTheme.brandGreen, Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRiderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rider Details',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1976&auto=format&fit=crop',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ahmed Ali',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Joined June 2023',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '4.9 (1.2k Reviews)',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _riderActionBtn(Icons.call_rounded, 'Call', AppTheme.brandGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _riderActionBtn(Icons.chat_bubble_rounded, 'Message', AppTheme.brandGreen.withOpacity(0.1), textColor: AppTheme.brandGreen),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _riderActionBtn(IconData icon, String label, Color bg, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAction(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  void _showDeliveredPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.brandGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_rounded, color: AppTheme.brandGreen, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Delivered!',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your groceries have been successfully delivered to your doorstep. Enjoy!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDeliveredScreen(
                        order: widget.order,
                        appState: widget.appState,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Great!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debugAdvanceButton() {
    return GestureDetector(
      onTap: () {
        int nextStatus = widget.order.statusIndex + 1;
        if (nextStatus <= 3) {
          widget.appState.updateOrderStatus(widget.order.id, nextStatus);
          if (nextStatus == 3) {
            _showDeliveredPopup();
          } else {
            setState(() {});
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.brandGreen.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.refresh, color: AppTheme.brandGreen, size: 18),
      ),
    );
  }
}

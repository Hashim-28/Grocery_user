import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  final AppState appState;
  const OrdersScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Orders',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 20),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (_, __) {
          if (appState.orders.isEmpty) {
            return _emptyOrders();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.orders.length,
            itemBuilder: (_, i) {
              final order = appState.orders[i];
              return _OrderCard(
                order: order,
                onTrack: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      order: order,
                      appState: appState,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppTheme.accentGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('📦', style: TextStyle(fontSize: 56))),
          ),
          const SizedBox(height: 24),
          Text('No orders yet',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('Your order history will appear here',
              style: GoogleFonts.outfit(
                  fontSize: 14, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTrack;
  const _OrderCard({required this.order, required this.onTrack});

  static const _statusLabels = [
    'Order Received',
    'Being Prepared',
    'Out for Delivery',
    'Delivered',
  ];

  static const _statusColors = [
    AppTheme.brandGreen,
    AppTheme.orangeAccent,
    AppTheme.brandGreen,
    AppTheme.primaryGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabels[order.statusIndex];
    final statusColor = _statusColors[order.statusIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.id,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.date} · ${order.items.length} item${order.items.length > 1 ? 's' : ''} · ${order.paymentMethod}',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1, color: AppTheme.accentGreen),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₨${order.total.toInt()}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                TextButton.icon(
                  onPressed: onTrack,
                  icon: const Icon(Icons.track_changes_rounded,
                      size: 16, color: AppTheme.primaryGreen),
                  label: Text('Track Order',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

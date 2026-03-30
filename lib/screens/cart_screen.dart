import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final AppState appState;
  const CartScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Cart',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: appState,
            builder: (_, __) => appState.cartItems.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmClear(context),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.outfit(
                          color: Colors.white70, fontSize: 13),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (_, __) {
          if (appState.cartItems.isEmpty) {
            return _emptyCart();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.cartItems.length,
                  itemBuilder: (_, i) {
                    final item = appState.cartItems[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(item.product.emoji,
                                    style: const TextStyle(fontSize: 32)),
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
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    item.product.weight,
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppTheme.textLight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₨${item.product.price.toInt()} × ${item.quantity}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₨${item.total.toInt()}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _qtyBtn(Icons.remove_rounded, () =>
                                        appState.decreaseQuantity(item.product.id)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text('${item.quantity}',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          )),
                                    ),
                                    _qtyBtn(Icons.add_rounded, () =>
                                        appState.addToCart(item.product)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom checkout panel
              _buildCheckoutBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.accentGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
        ),
      );

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textMedium, fontSize: 14)),
              Text('₨${appState.cartTotal.toInt()}',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textMedium, fontSize: 14)),
              Text('₨60',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(thickness: 1, color: AppTheme.accentGreen),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, fontSize: 16,
                      color: AppTheme.textDark)),
              Text('₨${(appState.cartTotal + 60).toInt()}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.primaryGreen,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(appState: appState),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'Proceed to Checkout',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🛒', style: TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from home or categories',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Cart?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('Remove all items from cart?',
            style: GoogleFonts.outfit(color: AppTheme.textMedium)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppTheme.textMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              appState.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redBadge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Clear',
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

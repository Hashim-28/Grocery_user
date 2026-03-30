import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final AppState appState;
  final String deliveryType;
  final double deliveryFee;

  const PaymentScreen({
    super.key,
    required this.appState,
    required this.deliveryType,
    required this.deliveryFee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Cash on Delivery';
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.appState.totalCartPrice;
    final total = subtotal + widget.deliveryFee;

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
        title: Text(
          'Payment Method',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred payment method to complete the order.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildPaymentMethodCard(
              'Cash on Delivery',
              'Pay with cash when your order arrives.',
              Icons.payments_rounded,
              const Color(0xFF347928),
            ),
            
            const SizedBox(height: 32),
            _buildOrderSummary(subtotal, widget.deliveryFee, total),
            const SizedBox(height: 40),
            _buildPlaceOrderButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String title, String subtitle, IconData icon, Color color) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.brandGreen : const Color(0xFFF1F5F9),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.brandGreen.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.brandGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double fee, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '₨${subtotal.toInt()}'),
          const SizedBox(height: 14),
          _buildSummaryRow('Delivery Fee', '₨${fee.toInt()}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '₨${total.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.brandGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMedium,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return ElevatedButton(
      onPressed: _isPlacing ? null : _handlePlaceOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.brandGreen,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: AppTheme.brandGreen.withOpacity(0.4),
      ),
      child: _isPlacing
          ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Place Order',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              ],
            ),
    );
  }

  void _handlePlaceOrder() async {
    setState(() => _isPlacing = true);
    await Future.delayed(const Duration(seconds: 2));
    widget.appState.placeOrder(paymentMethod: _selectedMethod, deliveryType: widget.deliveryType);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(appState: widget.appState)),
        (route) => route.isFirst,
      );
    }
  }
}

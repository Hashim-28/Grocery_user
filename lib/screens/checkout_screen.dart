import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import 'order_tracking_screen.dart';
import 'payment_screen.dart';
import 'main_navigation.dart';

class CheckoutScreen extends StatefulWidget {
  final AppState appState;
  const CheckoutScreen({super.key, required this.appState});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryType = 'Standard';
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.appState.cartItems;
    final totalCount = widget.appState.totalCartCount;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Review Order',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$totalCount Items',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items in Cart',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            // Cart Items
            ...cartItems.map((item) => _CartItemRow(
                  item: item,
                  appState: widget.appState,
                )),
            const SizedBox(height: 32),
            
            // Delivery Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Address',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAddressEditDialog(context),
                  child: Text(
                    'CHANGE',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.brandGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressCard(),
            const SizedBox(height: 32),
            
            // Delivery Speed
            Text(
              'Delivery Speed',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSpeedOption(
                    'Standard',
                    '₨50',
                    'Received Within 24-48 Hours',
                    _deliveryType == 'Standard',
                    () => setState(() => _deliveryType = 'Standard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSpeedOption(
                    'Express',
                    '₨150',
                    'Received Within 2 Hours',
                    _deliveryType == 'Express',
                    () => setState(() => _deliveryType = 'Express'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Order Summary
            Text(
              'Order Summary',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  _buildPriceDetail('Subtotal', '₨${widget.appState.totalCartPrice.toInt()}'),
                  const SizedBox(height: 16),
                  _buildPriceDetail('Delivery Fee', '₨${_deliveryType == 'Standard' ? 50 : 150}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _buildPriceDetail(
                    'Total Amount',
                    '₨${(widget.appState.totalCartPrice + (_deliveryType == 'Standard' ? 50 : 150)).toInt()}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildProceedButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.brandGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppTheme.brandGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.appState.deliveryAddress,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedOption(String title, String price, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppTheme.brandGreen,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.textLight,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetail(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? AppTheme.textDark : AppTheme.textMedium,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
            color: isTotal ? AppTheme.brandGreen : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return ElevatedButton(
      onPressed: () => _proceedToPayment(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.brandGreen,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: AppTheme.brandGreen.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Proceed to Payment',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  void _showAddressEditDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.appState.deliveryAddress);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Address',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your delivery address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppTheme.textMedium)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              widget.appState.updateDeliveryAddress(controller.text);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          appState: widget.appState,
          deliveryType: _deliveryType,
          deliveryFee: _deliveryType == 'Standard' ? 50 : 150,
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final AppState appState;
  const _CartItemRow({required this.item, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: item.product.imageUrl != null
                  ? Image.network(item.product.imageUrl!, width: 50, fit: BoxFit.contain)
                  : Text(item.product.emoji, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.weight,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₨${item.product.price.toInt()}',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.brandGreen,
                  ),
                ),
              ],
            ),
          ),
          // Stepper
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _stepperBtn(Icons.remove_rounded, () => appState.decreaseQuantity(item.product.id)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
                _stepperBtn(Icons.add_rounded, () => appState.addToCart(item.product)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: icon == Icons.add_rounded ? AppTheme.brandGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (icon == Icons.remove_rounded)
               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Icon(
          icon, 
          size: 18, 
          color: icon == Icons.add_rounded ? Colors.white : AppTheme.textDark
        ),
      ),
    );
  }
}

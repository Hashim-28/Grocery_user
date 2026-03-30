import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'main_navigation.dart';
import 'order_tracking_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final AppState appState;
  const OrderSuccessScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    // Get the most recent order or a dummy ID
    final orderId = appState.orders.isNotEmpty ? appState.orders.first.id : "24081701";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.brandGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppTheme.brandGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Order Placed Successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Order Reference ID is #$orderId',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for shopping with Diesel Cash & Carry. Your order is being prepared.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Primary Button
              ElevatedButton(
                onPressed: () {
                  if (appState.orders.isNotEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          order: appState.orders.first,
                          appState: appState,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandGreen,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: AppTheme.brandGreen.withOpacity(0.4),
                ),
                child: Text(
                  'Track My Order',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Secondary Button
              OutlinedButton(
                onPressed: () => _goToHome(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  side: const BorderSide(color: AppTheme.brandGreen, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Go to Home',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainNavigation(appState: appState, initialIndex: 0)),
      (route) => false,
    );
  }
}

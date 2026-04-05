import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';

class GlobalCartBar extends StatefulWidget {
  final AppState appState;
  final VoidCallback onTap;

  const GlobalCartBar({super.key, required this.appState, required this.onTap});

  @override
  State<GlobalCartBar> createState() => _GlobalCartBarState();
}

class _GlobalCartBarState extends State<GlobalCartBar> {
  bool _isDismissed = false;
  int _lastCount = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (_, __) {
        final count = widget.appState.totalCartCount;
        
        // Re-appear if items are added
        if (count > _lastCount) {
          _isDismissed = false;
        }
        _lastCount = count;

        if (_isDismissed || count == 0) return const SizedBox.shrink();

        final remaining = widget.appState.remainingForFreeDelivery;
        final subtotal = widget.appState.cartSubtotal;

        return Dismissible(
          key: const Key('global-cart-bar-dismiss'),
          direction: DismissDirection.down,
          onDismissed: (_) => setState(() => _isDismissed = true),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.isDarkMode ? AppTheme.primaryGradient : null,
                color: AppTheme.isDarkMode ? null : AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(AppTheme.isDarkMode ? 0.4 : 0.2),
                    blurRadius: AppTheme.isDarkMode ? 20 : 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (remaining > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Add ₨ ${remaining.toInt()} more for FREE delivery',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'You unlocked FREE Delivery! 🎉',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          '$count Item${count > 1 ? 's' : ''}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'View Cart',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '₨${subtotal.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

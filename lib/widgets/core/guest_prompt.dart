import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../screens/auth/login_screen.dart';

Future<bool> showGuestPrompt(BuildContext context, AppState appState) async {
  if (!appState.isGuest) return false;

  await showDialog(
    context: context,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: AppTheme.surface.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.glassBorder),
        ),
        title: Text(
          'Login Required',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            color: AppTheme.textHeading, 
            fontSize: 18
          ),
        ),
        content: Text(
          'Please login to continue with this action.',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textBody, 
            fontSize: 14
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL', 
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted, 
                fontWeight: FontWeight.w800, 
                fontSize: 13
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                AppRouter.fade(LoginScreen(appState: appState)),
                (route) => false,
              );
            },
            child: Text(
              'LOGIN', 
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.primary, 
                fontWeight: FontWeight.w800, 
                fontSize: 13
              ),
            ),
          ),
        ],
      ),
    ),
  );
  return true;
}

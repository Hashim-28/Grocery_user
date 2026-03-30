import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'auth/login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(appState: AppState()),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Image 1)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.brandGreen,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 70,
              ),
            ),
            const SizedBox(height: 32),
            // Brand Name
            Text(
              'Diesel Cash & Carry',
              style: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppTheme.brandGreen,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Tagline
            Text(
              'Freshness delivered to your doorstep.',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.brandGreen.withOpacity(0.8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

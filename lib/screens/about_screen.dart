import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Text('About Desil', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(child: Text('🛒', style: TextStyle(fontSize: 50))),
                  ),
                  const SizedBox(height: 16),
                  Text('Desil Cash & Carry', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                  Text('Bulk & Retail Solutions', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMedium)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _section('Our Vision', 'To become Pakistan\'s leading digital grocery platform by providing bulk and retail solutions with unmatched quality and speed.'),
            const SizedBox(height: 24),
            _section('Our Story', 'Desil Cash & Carry started as a local warehouse solution in Lahore and has now evolved into a high-fidelity digital shopping experience for families and businesses alike.'),
            const SizedBox(height: 24),
            _section('Commitment to Quality', 'We source our Atta, Sabzi, and Meat directly from trusted suppliers to ensure you get only the freshest products every single day.'),
            const SizedBox(height: 40),
            Center(
              child: Text('Version 1.0.0 (Build 124)', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Text(content, style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMedium, height: 1.5)),
      ],
    );
  }
}

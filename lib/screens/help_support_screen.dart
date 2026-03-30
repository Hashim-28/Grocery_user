import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Text('Help & Support', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Frequently Asked Questions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          _faqItem('How to track my order?', 'You can track your order by going to the "Orders" tab and clicking on "Track Order" for any active delivery.'),
          _faqItem('What are the delivery charges?', 'Standard delivery is free for orders above ₨1000. Express delivery (45-60 mins) has a flat charge of ₨60.'),
          _faqItem('Can I return items?', 'Fresh products like Sabzi and Meat can be returned at the time of delivery if not found satisfactory.'),
          _faqItem('What payment methods are supported?', 'We support JazzCash, EasyPaisa, and Cash on Delivery.'),
          const SizedBox(height: 32),
          Text('Contact Information', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          _contactItem(Icons.email_outlined, 'Email Support', 'support@desil.pk'),
          _contactItem(Icons.phone_outlined, 'Helpline', '042-111-DESIL-1'),
          _contactItem(Icons.business_outlined, 'Head Office', 'Gulberg III, Lahore, Pakistan'),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.accentGreen, borderRadius: BorderRadius.circular(16)),
            child: Text(
              'Note: Our representative will get back to you within 2-4 hours via email or phone call. Online chat is currently unavailable.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMedium)),
        ),
      ],
    );
  }

  Widget _contactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textLight)),
              Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            ],
          ),
        ],
      ),
    );
  }
}

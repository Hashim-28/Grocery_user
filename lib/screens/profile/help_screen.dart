import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: Text(
          'HELP & SUPPORT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'FREQUENTLY ASKED QUESTIONS',
              [
                _buildFaqItem(
                  'How do I track my order?',
                  'Go to the Orders tab and select your active order to see real-time tracking.',
                ),
                _buildFaqItem(
                  'What are the delivery charges?',
                  'Delivery is free for orders above ₨1000. Otherwise, a flat fee of ₨150 applies.',
                ),
                _buildFaqItem(
                  'Can I return items?',
                  'Yes, perishable items can be returned at the time of delivery. Non-perishables within 7 days.',
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSection(
              'CONTACT US',
              [
                _buildContactItem(
                  Icons.support_agent_rounded,
                  'Customer Hotline',
                  '111-DIESEL-111',
                ),
                _buildContactItem(
                  Icons.email_outlined,
                  'Support Email',
                  'support@dieselgrocery.com',
                ),
                _buildContactItem(
                  Icons.chat_rounded,
                  'WhatsApp Support',
                  '+92 300 0000000',
                ),
              ],
            ),
            const SizedBox(height: 40),
            AppButton(
              label: 'START LIVE CHAT',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textHeading,
          ),
        ),
        iconColor: AppTheme.primary,
        collapsedIconColor: AppTheme.textMuted,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textBody,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textHeading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

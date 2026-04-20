import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_widgets.dart';
import '../../utils/app_state.dart';

class HelpScreen extends StatelessWidget {
  final AppState appState;
  const HelpScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
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
          body: appState.isSupportLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primary))
              : RefreshIndicator(
                  onRefresh: () => appState.fetchSupportData(),
                  color: AppTheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (appState.faqs.isNotEmpty) ...[
                          _buildSection(
                            'FREQUENTLY ASKED QUESTIONS',
                            appState.faqs
                                .map((f) => _buildFaqItem(f.question, f.answer))
                                .toList(),
                          ),
                          const SizedBox(height: 40),
                        ],
                        if (appState.contactDetails.isNotEmpty) ...[
                          _buildSection(
                            'CONTACT US',
                            appState.contactDetails
                                .map((c) => _buildContactItem(
                                      _getIconData(c.icon),
                                      c.label,
                                      c.value,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 40),
                        ],
                        if (appState.faqs.isEmpty &&
                            appState.contactDetails.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 80),
                              child: Column(
                                children: [
                                  Icon(Icons.support_agent_outlined,
                                      size: 64,
                                      color:
                                          AppTheme.textMuted.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No support information available',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        AppButton(
                          label: 'RELOAD SUPPORT INFO',
                          onPressed: () => appState.fetchSupportData(),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'email':
      case 'email_outlined':
        return Icons.email_outlined;
      case 'phone':
      case 'call':
        return Icons.phone_outlined;
      case 'chat':
      case 'whatsapp':
        return Icons.chat_outlined;
      case 'location':
      case 'place':
        return Icons.location_on_outlined;
      default:
        return Icons.support_agent_rounded;
    }
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
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
          ),
        ],
      ),
    );
  }
}

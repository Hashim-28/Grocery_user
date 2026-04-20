import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/widgets/core/app_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import 'auth/login_screen.dart';
import 'profile/personal_info_screen.dart';
import 'profile/address_book_screen.dart';
import 'profile/help_screen.dart';
import 'profile/about_screen.dart';
import 'dart:ui';

class ProfileScreen extends StatelessWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'MY PROFILE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Background Glows
              Positioned(
                top: 50,
                right: -100,
                child: _buildBackgroundGlow(
                    AppTheme.primary.withOpacity(0.05), 300),
              ),
              Positioned(
                bottom: 100,
                left: -150,
                child: _buildBackgroundGlow(
                    AppTheme.accent.withOpacity(0.04), 400),
              ),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    24, 24, 24, 120), // Increased bottom padding for nav bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 48),
                    _sectionTitle('ACCOUNT SETTINGS'),
                    const SizedBox(height: 16),
                    _buildMenu(
                      icon: Icons.person_outline_rounded,
                      label: 'Personal Information',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(
                            PersonalInfoScreen(appState: appState)),
                      ),
                    ),
                    _buildMenu(
                      icon: Icons.location_on_outlined,
                      label: 'Delivery Addresses',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(
                            AddressBookScreen(appState: appState)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle('APP PREFERENCES'),
                    const SizedBox(height: 16),
                    _buildToggleMenu(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      value: appState.isDarkMode,
                      onChanged: (v) => appState.toggleTheme(),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle('SUPPORT & INFORMATION'),
                    const SizedBox(height: 16),
                    _buildMenu(
                      icon: Icons.help_outline_rounded,
                      label: 'Help Center',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(HelpScreen(appState: appState)),
                      ),
                    ),
                    _buildMenu(
                      icon: Icons.info_outline_rounded,
                      label: 'About Diesel App',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(AboutScreen(appState: appState)),
                      ),
                    ),
                    const SizedBox(height: 56),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          appState.clearUserData();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            AppRouter.fade(LoginScreen(appState: appState)),
                            (_) => false,
                          );
                        },
                        icon: const Icon(Icons.power_settings_new_rounded,
                            color: Colors.redAccent, size: 20),
                        label: Text(
                          'LOGOUT',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                            fontSize: 12,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppRouter.slideFade(PersonalInfoScreen(appState: appState)),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: appState.photoUrl != null
                    ? AppImage(url: appState.photoUrl, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          (appState.fullName ?? '??')
                              .split(' ')
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .take(2)
                              .join()
                              .toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (appState.fullName ?? 'User Profile').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textHeading,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.phone ?? (appState.email ?? 'No info available'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child:
                  Icon(Icons.edit_rounded, color: AppTheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppTheme.textMuted,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildMenu(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textHeading,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenu({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textHeading,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

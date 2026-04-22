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
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Positioned(
                top: 50.h,
                right: -100.w,
                child: _buildBackgroundGlow(
                    AppTheme.primary.withOpacity(0.05), 300.r),
              ),
              Positioned(
                bottom: 100.h,
                left: -150.w,
                child: _buildBackgroundGlow(
                    AppTheme.accent.withOpacity(0.04), 400.r),
              ),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                    24.w, 24.h, 24.w, 120.h), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: 48.h),
                    _sectionTitle('ACCOUNT SETTINGS'),
                    SizedBox(height: 16.h),
                    _buildMenu(
                      context: context,
                      icon: Icons.person_outline_rounded,
                      label: 'Personal Information',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(
                            PersonalInfoScreen(appState: appState)),
                      ),
                    ),
                    _buildMenu(
                      context: context,
                      icon: Icons.location_on_outlined,
                      label: 'Delivery Addresses',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(
                            AddressBookScreen(appState: appState)),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    _sectionTitle('APP PREFERENCES'),
                    SizedBox(height: 16.h),
                    _buildToggleMenu(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      value: appState.isDarkMode,
                      onChanged: (v) => appState.toggleTheme(),
                    ),
                    SizedBox(height: 32.h),
                    _sectionTitle('SUPPORT & INFORMATION'),
                    SizedBox(height: 16.h),
                    _buildMenu(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      label: 'Help Center',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(HelpScreen(appState: appState)),
                      ),
                    ),
                    _buildMenu(
                      context: context,
                      icon: Icons.info_outline_rounded,
                      label: 'About Diesel App',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.slideFade(AboutScreen(appState: appState)),
                      ),
                    ),
                    SizedBox(height: 56.h),
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
                        icon: Icon(Icons.power_settings_new_rounded,
                            color: Colors.redAccent, size: 20.sp),
                        label: Text(
                          'LOGOUT',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                            fontSize: 12.sp,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
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
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36.r),
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
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (appState.fullName ?? 'User Profile').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textHeading,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    appState.phone ?? (appState.email ?? 'No info available'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child:
                  Icon(Icons.edit_rounded, color: AppTheme.primary, size: 18.sp),
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
        fontSize: 11.sp,
        fontWeight: FontWeight.w900,
        color: AppTheme.textMuted,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildMenu(
      {required BuildContext context,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 22.sp),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textHeading,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textMuted, size: 14.sp),
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
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22.sp),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
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

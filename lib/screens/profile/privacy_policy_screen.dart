import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final AppState appState;
  const PrivacyPolicyScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'PRIVACY POLICY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 32.h),
                _buildSection(
                  'Introduction',
                  'At Diesel, we are committed to protecting your privacy and ensuring that your personal information is handled in a safe and responsible manner. This Privacy Policy outlines how we collect, use, and protect your information.',
                ),
                _buildSection(
                  'Data We Collect',
                  'We collect information that you provide directly to us, such as when you create an account, place an order, or contact our support team. This may include your name, email address, phone number, and delivery address.',
                ),
                _buildSection(
                  'How We Use Your Data',
                  'Your data is used to process your orders, provide customer support, and improve our services. We may also use your information to send you updates about our latest deals and promotions, which you can opt-out of at any time.',
                ),
                _buildSection(
                  'Data Security',
                  'We implement a variety of security measures to maintain the safety of your personal information. Your data is stored on secure servers and is only accessible by authorized personnel.',
                ),
                _buildSection(
                  'Your Rights',
                  'You have the right to access, correct, or delete your personal information at any time. If you have any questions or concerns about your data, please contact our support team through the Help Center.',
                ),
                SizedBox(height: 40.h),
                _buildFooter(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: Colors.white, size: 40.sp),
          SizedBox(height: 16.h),
          Text(
            'Your privacy is our priority',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Last updated: April 2026',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: AppTheme.textBody,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'DIESEL CASH & CARRY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '© 2026 Diesel. All rights reserved.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

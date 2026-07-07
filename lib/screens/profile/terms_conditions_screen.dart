import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';

class TermsConditionsScreen extends StatelessWidget {
  final AppState appState;
  const TermsConditionsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'TERMS & CONDITIONS',
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
                  '1. Acceptance of Terms',
                  'By accessing or using the Diesel application, you agree to be bound by these Terms and Conditions and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using this app.',
                ),
                _buildSection(
                  '2. Use License',
                  'Permission is granted to temporarily download one copy of the materials (information or software) on Diesel\'s application for personal, non-commercial transitory viewing only.',
                ),
                _buildSection(
                  '3. User Account',
                  'You are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer or mobile device. You agree to accept responsibility for all activities that occur under your account.',
                ),
                _buildSection(
                  '4. Product Accuracy',
                  'The materials appearing on Diesel\'s application could include technical, typographical, or photographic errors. Diesel does not warrant that any of the materials on its application are accurate, complete, or current.',
                ),
                _buildSection(
                  '5. Limitation of Liability',
                  'In no event shall Diesel or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the Diesel app.',
                ),
                _buildSection(
                  '6. Governing Law',
                  'These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction where Diesel operates and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.',
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
          colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel_rounded, color: Colors.white, size: 40.sp),
          SizedBox(height: 16.h),
          Text(
            'Usage Guidelines',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please read carefully',
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
              color: AppTheme.accent,
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
            'Terms and Conditions • Version 1.0',
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

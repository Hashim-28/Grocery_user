import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import '../main_navigation.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  final AppState appState;
  const SignupScreen({super.key, required this.appState});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        data: {
          'full_name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'role': 'user',
        },
      );

      if (response.user == null) {
        throw 'Registration failed';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Registration successful! Welcome to Diesel Cash & Carry.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        AppRouter.fade(MainNavigation(appState: widget.appState)),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthMessage(e.message)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('already registered') || lower.contains('already been registered') || lower.contains('user_already_exists')) {
      return 'An account with this email already exists. Please login instead.';
    }
    if (lower.contains('password') && (lower.contains('short') || lower.contains('weak') || lower.contains('at least'))) {
      return 'Password is too weak. Please use at least 6 characters.';
    }
    if (lower.contains('invalid email') || lower.contains('valid email')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('too many requests') || lower.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }
    if (lower.contains('network') || lower.contains('socket') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    return message;
  }

  String _friendlyErrorMessage(Object e) {
    final msg = e.toString();
    final lower = msg.toLowerCase();
    if (lower.contains('network') || lower.contains('socket') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (lower.contains('permission') || lower.contains('denied')) {
      return 'Access denied. Please contact support.';
    }
    final colonIndex = msg.indexOf(': ');
    if (colonIndex != -1 && colonIndex < 40) {
      return msg.substring(colonIndex + 2);
    }
    if (msg.startsWith('Exception')) return 'Something went wrong. Please try again.';
    return msg.length > 120 ? 'Something went wrong. Please try again.' : msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left_rounded, size: 28.sp),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 100.h,
            left: -150.w,
            child:
                _buildBackgroundGlow(AppTheme.primary.withOpacity(0.08), 400.r),
          ),
          Positioned(
            bottom: 200.h,
            right: -100.w,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.06), 300.r),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Text(
                      'NEW USER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 4.0,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Create Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textHeading,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Join the next-gen logistics network for seamless grocery distribution.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        color: AppTheme.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 48.h),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'Enter Full Name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().length < 3)
                          return 'Name too short';
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'Enter Email Address',
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Email required';
                        if (!v.contains('@')) return 'Invalid email address';
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: 'Mobile Number',
                      hint: 'Enter Mobile Number',
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Mobile number required';
                        if (v.trim().length < 10)
                          return 'Enter a valid mobile number';
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    AppTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: 'At least 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _register(),
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18.sp,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password required';
                        return null;
                      },
                    ),
                    SizedBox(height: 48.h),
                    AppButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _register,
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: Text(
                        'BY PROCEEDING, YOU AGREE TO PROTOCOLS.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
}

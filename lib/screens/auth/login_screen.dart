import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import '../main_navigation.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'verify_otp_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;
  const LoginScreen({super.key, required this.appState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (response.user == null) {
        throw 'Login failed';
      }

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      await widget.appState.fetchProfile();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        AppRouter.fade(MainNavigation(appState: widget.appState)),
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
    if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email.';
    }
    if (lower.contains('too many requests') || lower.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }
    if (lower.contains('network') || lower.contains('socket') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    // Return the message as-is if it's already clean
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
    // Strip class prefixes like "Exception: ..." or "PostgrestException: ..."
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
      body: Stack(
        children: [
          // Top Image Cover
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 0.48.sh, // Using sh (screen height) from ScreenUtil
            child: Image.asset(
              'assets/images/groceroy.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 0.48.sh,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    AppTheme.scaffold.withOpacity(0.1),
                    AppTheme.scaffold.withOpacity(0.8),
                    AppTheme.scaffold,
                  ],
                  stops: const [0.0, 0.4, 0.8, 0.95, 1.0],
                ),
              ),
            ),
          ),

          // Foreground Content (Bottom Sheet Style)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 0.65.sh, 
              decoration: BoxDecoration(
                color: AppTheme.scaffold,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30.r,
                    offset: Offset(0, -5.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28.r)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16.h),
                        Container(
                          width: 48.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 28.h),

                        Text(
                          'DIESEL CASH & CARRY',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textHeading,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Pakistan's #1 Premium Grocery Delivery",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 36.h),

                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Log in or sign up',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        AppTextField(
                          controller: _emailCtrl,
                          label: 'EMAIL',
                          hint: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email required';
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        AppTextField(
                          controller: _passCtrl,
                          label: 'PASSWORD',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePass,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20.sp,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Password required';
                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                AppRouter.slideFade(ForgotPasswordScreen(appState: widget.appState)),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        AppButton(
                          label: 'Continue',
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _login,
                        ),

                        SizedBox(height: 24.h),

                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'or',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New to Diesel? ",
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textMuted,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                AppRouter.slideFade(
                                    SignupScreen(appState: widget.appState)),
                              ),
                              child: Text(
                                'Create account',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 48.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

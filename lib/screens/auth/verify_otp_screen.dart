import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import '../main_navigation.dart';

class VerifyOtpScreen extends StatefulWidget {
  final AppState appState;
  final String email;
  final OtpType type;

  const VerifyOtpScreen({
    super.key,
    required this.appState,
    required this.email,
    required this.type,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Verify the OTP
      final response = await supabase.auth.verifyOTP(
        email: widget.email,
        token: _otpCtrl.text.trim(),
        type: widget.type,
      );

      if (response.user == null) {
        throw 'Verification failed. Invalid or expired OTP.';
      }

      // If it's a password recovery, update the password
      if (widget.type == OtpType.recovery) {
        await supabase.auth.updateUser(
          UserAttributes(password: _newPassCtrl.text.trim()),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // After successful verification (and optional password update), navigate to MainNavigation
      if (!mounted) return;
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

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      if (widget.type == OtpType.recovery) {
        await supabase.auth.resetPasswordForEmail(widget.email);
      } else {
        await supabase.auth.resend(
          type: OtpType.signup,
          email: widget.email,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new OTP has been sent to your email.'),
          backgroundColor: Colors.green,
        ),
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
    if (lower.contains('otp') && (lower.contains('expired') || lower.contains('invalid'))) {
      return 'Invalid or expired OTP. Please request a new one.';
    }
    if (lower.contains('token') && (lower.contains('expired') || lower.contains('invalid'))) {
      return 'Invalid or expired code. Please request a new one.';
    }
    if (lower.contains('too many requests') || lower.contains('rate limit') || lower.contains('limit') || lower.contains('exceed')) {
      return 'Too many attempts. Please try again later.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email.';
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
    final colonIndex = msg.indexOf(': ');
    if (colonIndex != -1 && colonIndex < 40) {
      return msg.substring(colonIndex + 2);
    }
    if (msg.startsWith('Exception')) return 'Something went wrong. Please try again.';
    return msg.length > 120 ? 'Something went wrong. Please try again.' : msg;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 100,
            left: -150,
            child:
                _buildBackgroundGlow(AppTheme.primary.withOpacity(0.08), 400),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.06), 300),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      widget.type == OtpType.recovery
                          ? 'PASSWORD RESET'
                          : 'VERIFICATION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.type == OtpType.recovery
                          ? 'Enter OTP'
                          : 'Verify Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textHeading,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'An OTP has been sent to ${widget.email}. Please enter it below to proceed.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    AppTextField(
                      controller: _otpCtrl,
                      label: 'OTP Code',
                      hint: 'Enter 6-digit OTP',
                      prefixIcon: Icons.lock_clock_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'OTP required';
                        if (v.trim().length != 8) return 'OTP must be 8 digits';
                        return null;
                      },
                    ),
                    if (widget.type == OtpType.recovery) ...[
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _newPassCtrl,
                        label: 'New Password',
                        hint: 'At least 6 characters',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscureNewPass,
                        suffix: IconButton(
                          onPressed: () => setState(
                              () => _obscureNewPass = !_obscureNewPass),
                          icon: Icon(
                            _obscureNewPass
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password required';
                          if (v.length < 8)
                            return 'Password must be at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _confirmPassCtrl,
                        label: 'Confirm Password',
                        hint: 'Re-enter your new password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirmPass,
                        suffix: IconButton(
                          onPressed: () => setState(
                              () => _obscureConfirmPass = !_obscureConfirmPass),
                          icon: Icon(
                            _obscureConfirmPass
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Confirm password required';
                          if (v != _newPassCtrl.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 48),
                    AppButton(
                      label: widget.type == OtpType.recovery
                          ? 'Reset Password'
                          : 'Verify & Continue',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _verify,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        child: Text(
                          "Didn't receive the code? Resend OTP",
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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

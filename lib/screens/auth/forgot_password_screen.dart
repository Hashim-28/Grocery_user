import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AppState appState;
  
  const ForgotPasswordScreen({super.key, required this.appState});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      String identifier = _emailCtrl.text.trim();
      String? email;

      // Check if the input is a phone number
      final phoneRegex = RegExp(r'^\+?[0-9]+$');
      if (phoneRegex.hasMatch(identifier) && !identifier.contains('@')) {
        final numericPhone = identifier.replaceAll(RegExp(r'[^0-9]'), '');
        
        // Try to find the email by checking multiple variations
        final List<dynamic> searchTerms = [];
        searchTerms.add(numericPhone);
        
        final pInt = int.tryParse(numericPhone);
        if (pInt != null) searchTerms.add(pInt);
        
        // If it starts with 0 (e.g. 0300...), try without 0
        if (numericPhone.startsWith('0')) {
          final stripped = numericPhone.substring(1);
          searchTerms.add(stripped);
          final sInt = int.tryParse(stripped);
          if (sInt != null) searchTerms.add(sInt);
        }
        
        // If it starts with 92 (e.g. 92300...), try without 92
        if (numericPhone.startsWith('92')) {
          final stripped = numericPhone.substring(2);
          searchTerms.add(stripped);
          final sInt = int.tryParse(stripped);
          if (sInt != null) searchTerms.add(sInt);
        }

        final profilesData = await supabase
            .from('profiles')
            .select('email')
            .filter('phone', 'in', '(${searchTerms.join(',')})')
            .limit(1);
          
        if (profilesData.isNotEmpty && profilesData[0]['email'] != null) {
          email = profilesData[0]['email'];
        }
      }

      // Fallback
      email ??= identifier;

      await supabase.auth.resetPasswordForEmail(email);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        AppRouter.slideFade(
          VerifyOtpScreen(
            appState: widget.appState,
            email: email,
            type: OtpType.recovery,
          ),
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
    if (lower.contains('user not found')) {
      return 'No account found with this email or phone number.';
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
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 100,
            left: -150,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.08), 400),
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
                      'RECOVERY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Forgot Password?',
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
                        'Enter your email or phone and we will send you an OTP to reset your password.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email or Phone',
                      hint: 'Enter your email or phone',
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email or Phone required';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 48),
                    
                    AppButton(
                      label: 'Send OTP',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _sendOtp,
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

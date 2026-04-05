import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import '../main_navigation.dart';
import 'dart:ui';

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
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      AppRouter.fade(MainNavigation(appState: widget.appState)),
      (_) => false,
    );
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
                      'NEW USER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create Account',
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
                      'Join the next-gen logistics network for seamless grocery distribution.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'Enter Full Name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().length < 3) return 'Designation required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email or Mobile Number',
                      hint: 'Enter Email or Mobile Number',
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Identifier required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: 'At least 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _register(),
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(
                          _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 18,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Access key required';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 48),
                    AppButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _register,
                    ),
                    
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'BY PROCEEDING, YOU AGREE TO PROTOCOLS.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.0,
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


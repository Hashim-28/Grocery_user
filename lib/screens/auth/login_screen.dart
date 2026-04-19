import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../widgets/core/app_widgets.dart';
import '../main_navigation.dart';
import 'signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // Fetch profile and role from 'profiles' table
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      final String actualRole = profile['role'] ?? 'user';

      // Verify if user has correct role (user, admin, or staff)
      // For the user app, we generally allow all roles, but prioritize 'user'
      // If you want to restrict it strictly to 'user', uncomment the next block:
      /*
      if (actualRole != 'user') {
        await supabase.auth.signOut();
        throw 'Access denied: Please use the Admin app.';
      }
      */

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        AppRouter.fade(MainNavigation(appState: widget.appState)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: Stack(
        children: [
          // Top Image Cover
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height *
                0.48, // slightly bigger to match Zomato proportions
            child: Image.asset(
              'assets/images/groceroy.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay to blend the image gently (Zomato style)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.48,
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
              height: size.height * 0.65, // bottom sheet covers bottom 65%
              decoration: BoxDecoration(
                color: AppTheme.scaffold,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // deeper shadow for popping effect
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Small handle for sheet-like look
                        Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Brand Title like Zomato
                        Text(
                          'DIESEL CASH & CARRY',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textHeading,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Pakistan's #1 Premium Grocery Delivery",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Zomato style "Log in or sign up" section divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Log in or sign up',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Form Fields (Email/Password)
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
                        const SizedBox(height: 16),

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
                              size: 20,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Password required';
                            return null;
                          },
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Continue Button
                        AppButton(
                          label: 'Continue',
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _login,
                        ),

                        const SizedBox(height: 24),

                        // OR divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppTheme.glassBorder, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Continue as guest
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                AppRouter.fade(
                                    MainNavigation(appState: widget.appState)),
                              );
                            },
                            icon: Icon(Icons.person_outline,
                                color: AppTheme.textHeading, size: 20),
                            label: Text(
                              "Continue as guest",
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textHeading,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppTheme.glassBorder, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Signup Text at very bottom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New to Diesel? ",
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textMuted,
                                fontSize: 14,
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
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import 'signup_screen.dart';
import '../main_navigation.dart';

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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainNavigation(appState: widget.appState),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Login or Register',
          style: GoogleFonts.outfit(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Log in to your account to continue\nshopping',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppTheme.textMedium,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Email Field
                Text(
                  'Email or Mobile Number',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    hintText: 'Email or Mobile Number',
                    hintStyle: GoogleFonts.outfit(
                      color: AppTheme.textLight.withOpacity(0.4),
                    ),
                    prefixIcon: const Icon(Icons.person, size: 22),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.brandGreen),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
                    bool isPhone = RegExp(r'^[0-9]{10,11}$').hasMatch(v.replaceAll(' ', ''));
                    if (!isEmail && !isPhone) return 'Enter valid email or phone';
                    return null;
                  },
                ),
                
                const SizedBox(height: 28),
                
                // Password Field
                Text(
                  'Password',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.outfit(
                      color: AppTheme.textLight.withOpacity(0.4),
                    ),
                    prefixIcon: const Icon(Icons.lock, size: 22),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.brandGreen),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: AppTheme.textLight,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) => (v != null && v.length >= 6) ? null : 'Minimum 6 characters',
                ),
                
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.outfit(
                        color: AppTheme.brandGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Login',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.outfit(
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignupScreen(appState: widget.appState)),
                          );
                        },
                        child: Text(
                          'Register',
                          style: GoogleFonts.outfit(
                            color: AppTheme.brandGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

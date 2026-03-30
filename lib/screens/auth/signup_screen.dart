import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../main_navigation.dart';

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

  String _selectedCountryCode = '+92';
  final List<String> _countryCodes = [
    '+92', '+91', '+1', '+44', '+971', '+966', '+61', '+81', '+49', '+33'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _signup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigation(appState: widget.appState),
        ),
      );
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
          'Create Account',
          style: GoogleFonts.outfit(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'Join Diesel Cash & Carry',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register to start shopping for fresh groceries',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            
            _label('Full Name'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
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
              validator: (v) => (v != null && v.isNotEmpty) ? null : 'Required',
            ),
            
            const SizedBox(height: 24),
            
            _label('Email Address'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                hintStyle: GoogleFonts.outfit(
                  color: AppTheme.textLight.withOpacity(0.4),
                ),
                prefixIcon: const Icon(Icons.email, size: 22),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.brandGreen),
                ),
              ),
              validator: (v) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v ?? '') ? null : 'Invalid email',
            ),
            
            const SizedBox(height: 24),
            
            _label('Mobile Number'),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      onChanged: (String? newValue) {
                        setState(() => _selectedCountryCode = newValue!);
                      },
                      items: _countryCodes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '300 1234567',
                      hintStyle: GoogleFonts.outfit(
                        color: AppTheme.textLight.withOpacity(0.4),
                      ),
                      prefixIcon: const Icon(Icons.phone_android, size: 22),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppTheme.brandGreen),
                      ),
                    ),
                    validator: (v) => (v != null && v.length >= 7) ? null : 'Invalid number',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _label('Password'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                hintText: 'Enter secure password',
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
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) _signup();
                },
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
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Log in',
                      style: GoogleFonts.outfit(
                        color: AppTheme.brandGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text.rich(
                  TextSpan(
                    text: 'By registering, you agree to our ',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: GoogleFonts.outfit(color: AppTheme.textLight, decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: GoogleFonts.outfit(color: AppTheme.textLight, decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: AppTheme.textDark,
        ),
      );
}

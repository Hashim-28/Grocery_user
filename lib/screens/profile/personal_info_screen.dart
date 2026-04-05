import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../widgets/core/app_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

class PersonalInfoScreen extends StatefulWidget {
  final AppState appState;
  const PersonalInfoScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return _PersonalInfoScreenContent(appState: appState);
  }

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameCtrl = TextEditingController(text: 'Hashim Ali');
  final _emailCtrl = TextEditingController(text: 'hashim@example.com');
  final _phoneCtrl = TextEditingController(text: '0300 1234567');

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile picture selected: ${image.name}'),
          backgroundColor: AppTheme.surfaceVariant,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: Text(
          'PERSONAL INFO',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Saved')),
              );
              Navigator.pop(context);
            },
            child: Text(
              'SAVE',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 150, spreadRadius: 50),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary, width: 2),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            color: AppTheme.surface,
                            child: widget.appState.profileImagePath != null
                                ? Image.asset(widget.appState.profileImagePath!, fit: BoxFit.cover)
                                : Center(
                                    child: Text(
                                      'HA',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                AppTextField(
                  controller: _nameCtrl,
                  label: 'FULL NAME',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'EMAIL ADDRESS',
                  hint: 'user@example.com',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _phoneCtrl,
                  label: 'PHONE NUMBER',
                  hint: '03XX XXXXXXX',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 48),
                Text(
                  'SECURE ACCOUNT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMuted,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your personal information is stored securely and is only used to facilitate your orders and delivery.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textMuted.withOpacity(0.7),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoScreenContent extends StatefulWidget {
  final AppState appState;
  const _PersonalInfoScreenContent({required this.appState});

  @override
  State<_PersonalInfoScreenContent> createState() => _PersonalInfoScreenContentState();
}

class _PersonalInfoScreenContentState extends State<_PersonalInfoScreenContent> {
  // Transfer logic to the main state if needed, but for now I'll just keep the UI in one place
  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // Placeholder as it's handled above
  }
}


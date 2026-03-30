import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  final AppState appState;
  const EditProfileScreen({super.key, required this.appState});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Muhammad Ali');
    _emailCtrl = TextEditingController(text: 'ali@desil.pk');
    _phoneCtrl = TextEditingController(text: '0300-1234567');
    _addressCtrl = TextEditingController(text: widget.appState.deliveryAddress);
    _localImagePath = widget.appState.profileImagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.appState.updateDeliveryAddress(_addressCtrl.text);
    if (_localImagePath != null) {
      widget.appState.updateProfileImage(_localImagePath!);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _localImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryGreen, width: 2),
                      image: _localImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_localImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _localImagePath == null
                        ? const Center(child: Text('👨‍💼', style: TextStyle(fontSize: 48)))
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _field('Full Name', _nameCtrl, Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _field('Email Address', _emailCtrl, Icons.email_outlined),
            const SizedBox(height: 20),
            _field('Phone Number', _phoneCtrl, Icons.phone_outlined),
            const SizedBox(height: 20),
            _field('Default Address', _addressCtrl, Icons.location_on_outlined),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save Changes', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen)),
          ),
        ),
      ],
    );
  }
}

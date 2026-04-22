import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/utils/error_handler.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import 'dart:ui';

class LocationPickerScreen extends StatelessWidget {
  final AppState appState;
  const LocationPickerScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final addresses = appState.addresses;

        return Scaffold(
          backgroundColor: AppTheme.scaffold,
          appBar: AppBar(
            title: Text(
              'SELECT NODE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Background Glow
              Positioned(
                top: 200,
                right: -100,
                child: _buildBackgroundGlow(
                    AppTheme.primary.withOpacity(0.05), 300),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textHeading),
                          decoration: InputDecoration(
                            hintText: 'SCAN FOR AREA, STREET...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                            prefixIcon: Icon(Icons.radar_rounded,
                                color: AppTheme.primary, size: 20),
                            filled: true,
                            fillColor: AppTheme.surface.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: AppTheme.glassBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: AppTheme.glassBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: AppTheme.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () async {
                        String? _tempPhone;
                        try {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary),
                              ),
                            ),
                          );

                          final address =
                              await appState.getCurrentLocationAddress();

                          if (!context.mounted) return;
                          Navigator.pop(context); // Close loading dialog

                          if (address != null) {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.surface,
                                title: Text(
                                  'LOCATION FOUND',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppTheme.textHeading,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Found address:\n$address\n\nWould you like to save this as a new address?',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: TextEditingController(text: appState.phone),
                                      onChanged: (val) => _tempPhone = val,
                                      keyboardType: TextInputType.phone,
                                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textHeading),
                                      decoration: InputDecoration(
                                        labelText: 'DELIVERY PHONE',
                                        labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800),
                                        prefixIcon: Icon(Icons.phone_android_rounded, color: AppTheme.primary, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('CANCEL',
                                        style: GoogleFonts.plusJakartaSans(
                                            color: AppTheme.textMuted)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      final phoneToSave = (_tempPhone ?? appState.phone) ?? '';
                                      Navigator.pop(context);
                                      await appState.addAddress(
                                          'My Location', address, phoneToSave);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Address saved successfully!')),
                                        );
                                      }
                                    },
                                    child: Text('SAVE ADDRESS',
                                        style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // Close loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text(ErrorHandler.getFriendlyMessage(e))),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.my_location_rounded,
                                  color: AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AUTO-SCAN LOCATION',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'FIND CURRENT LOCATION VIA GPS',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppTheme.glassBorder),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                    child: Text(
                      'SAVED ADDRESSES',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final addr = addresses[i];
                        final isSelected = addr.isDefault;
                        return GestureDetector(
                          onTap: () {
                            appState.setDefaultAddress(addr.id);
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary.withOpacity(0.05)
                                  : AppTheme.surface.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.glassBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.home_filled,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    addr.location,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 14,
                                      color: isSelected
                                          ? AppTheme.textHeading
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded,
                                      color: AppTheme.primary, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

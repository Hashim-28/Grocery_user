import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import 'dart:ui';

class AddressBookScreen extends StatelessWidget {
  final AppState appState;
  const AddressBookScreen({super.key, required this.appState});

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
          'DELIVERY NODES',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddAddress(context),
            icon: Icon(Icons.add_location_alt_rounded, color: AppTheme.primary, size: 22),
            tooltip: 'Initialize new node',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            bottom: 100,
            left: -100,
            child: _buildBackgroundGlow(AppTheme.primary.withOpacity(0.05), 300),
          ),

          appState.isAddressesLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : addresses.isEmpty
                ? Center(
                    child: Text(
                      'No addresses found.',
                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: addresses.length,
              itemBuilder: (context, i) {
                final addr = addresses[i];
                final isDefault = addr.isDefault;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDefault ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDefault ? AppTheme.primary : AppTheme.glassBorder,
                      width: isDefault ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDefault ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  addr.icon == 'base' ? Icons.home_filled : 
                                  addr.icon == 'node' ? Icons.business_center_rounded : 
                                  Icons.location_history_rounded,
                                  color: isDefault ? AppTheme.primary : AppTheme.textMuted,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                addr.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isDefault ? AppTheme.primary : AppTheme.textHeading,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        addr.location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => appState.deleteAddress(addr.id),
                            child: Text(
                              'DELETE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!isDefault)
                            ElevatedButton(
                              onPressed: () => appState.setDefaultAddress(addr.id),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 36),
                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                                foregroundColor: AppTheme.primary,
                                side: BorderSide(color: AppTheme.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                'SET AS DEFAULT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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

  void _showAddAddress(BuildContext context) {
    final _nameCtrl = TextEditingController();
    final _addrCtrl = TextEditingController();
    final _cityCtrl = TextEditingController();
    final _postalCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 40),
          decoration: BoxDecoration(
            color: AppTheme.scaffold.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: AppTheme.glassBorder)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textHeading,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameCtrl,
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.textHeading),
                  decoration: InputDecoration(
                    labelText: 'ADDRESS NAME (e.g. Home, Work)',
                    labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                    prefixIcon: Icon(Icons.label_important_rounded, color: AppTheme.primary, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _addrCtrl,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.textHeading),
                  decoration: InputDecoration(
                    labelText: 'STREET ADDRESS',
                    labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                    prefixIcon: Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _cityCtrl,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textHeading),
                        decoration: InputDecoration(
                          labelText: 'CITY',
                          labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                          prefixIcon: Icon(Icons.location_city_rounded, color: AppTheme.primary, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _postalCtrl,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textHeading),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'POSTAL',
                          labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameCtrl.text.isNotEmpty && _addrCtrl.text.isNotEmpty && _cityCtrl.text.isNotEmpty) {
                      final fullLocation = '${_addrCtrl.text}, ${_cityCtrl.text}' + 
                          (_postalCtrl.text.isNotEmpty ? ' ${_postalCtrl.text}' : '');
                          
                      await appState.addAddress(_nameCtrl.text, fullLocation);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address Saved')),
                        );
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: const Text('SAVE ADDRESS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


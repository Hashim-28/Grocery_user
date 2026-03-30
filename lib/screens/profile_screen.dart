import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'auth/login_screen.dart';
import 'profile_edit_screen.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Account'),
                  const SizedBox(height: 10),
                  _buildMenu(context),
                  const SizedBox(height: 24),
                  _sectionTitle('Orders Summary'),
                  const SizedBox(height: 10),
                  _buildStats(),
                  const SizedBox(height: 24),
                  _logoutButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: AnimatedBuilder(
                  animation: appState,
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: appState.profileImagePath != null
                        ? Image.file(
                            File(appState.profileImagePath!),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1976&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, _, __) => const Center(child: Text('👨‍💼', style: TextStyle(fontSize: 44))),
                          ),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.orangeAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Muhammad Ali',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ali@desil.pk · 0300-1234567',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: appState,
                  builder: (_, __) => Text(
                    appState.deliveryAddress,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final items = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Edit Profile',
        'screen': EditProfileScreen(appState: appState)
      },
      {'icon': Icons.location_on_outlined, 'label': 'Saved Addresses'},
      {
        'icon': Icons.help_outline_rounded,
        'label': 'Help & Support',
        'screen': const HelpSupportScreen()
      },
      {
        'icon': Icons.info_outline_rounded,
        'label': 'About Desil',
        'screen': const AboutScreen()
      },
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: AppTheme.primaryGreen, size: 20),
                ),
                title: Text(
                  item['label'] as String,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppTheme.textLight),
                onTap: () {
                  if (item['label'] == 'Saved Addresses') {
                    _showAddressEditDialog(context);
                  } else if (item.containsKey('screen')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => item['screen'] as Widget,
                      ),
                    );
                  }
                },
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 70)
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStats() {
    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        final orders = appState.orders;
        final completed = orders.where((o) => o.statusIndex == 3).length;
        final total = orders.fold(0.0, (s, o) => s + o.total);
        return Row(
          children: [
            _statCard('📦', '${orders.length}', 'Total Orders'),
            const SizedBox(width: 12),
            _statCard('✅', '$completed', 'Completed'),
            const SizedBox(width: 12),
            _statCard('₨',
                total > 0 ? '${total.toInt()}' : '0', 'Total Spent'),
          ],
        );
      },
    );
  }

  Widget _statCard(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 10, color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      );

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LoginScreen(appState: appState),
          ),
          (_) => false,
        ),
        icon: const Icon(Icons.logout_rounded, color: AppTheme.redBadge),
        label: Text(
          'Logout',
          style: GoogleFonts.outfit(
            color: AppTheme.redBadge,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _showAddressEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: appState.deliveryAddress);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Saved Address', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Enter your delivery address',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appState.updateDeliveryAddress(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

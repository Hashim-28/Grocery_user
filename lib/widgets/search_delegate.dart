import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_data.dart';
import '../utils/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/core/app_widgets.dart';
import 'dart:ui';

class ProductSearchDelegate extends SearchDelegate {
  final AppState appState;
  ProductSearchDelegate({required this.appState});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return AppTheme.themeData.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.scaffold,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppTheme.textHeading,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.surfaceVariant.withOpacity(0.5),
        hintStyle: TextStyle(color: AppTheme.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }

  @override
  String? get searchFieldLabel => 'Search groceries...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = AppData.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      color: AppTheme.scaffold,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: results.length,
        itemBuilder: (_, i) => ProductCard(
          product: results[i],
          appState: appState,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty 
        ? [] 
        : AppData.products
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Container(
      color: AppTheme.scaffold,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: suggestions.length,
        itemBuilder: (_, i) {
          final p = suggestions[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.glassBorder, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(
                  url: p.imageUrl,
                  fit: BoxFit.contain,
                  fallbackEmoji: p.emoji,
                  width: 35,
                ),
              ),
            ),
            title: Text(
              p.name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppTheme.textHeading,
              ),
            ),
            subtitle: Text(
              '₨${p.price.toInt()} · ${p.category.toUpperCase()}',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
            trailing: Icon(Icons.north_west_rounded, size: 18, color: AppTheme.textMuted),
            onTap: () {
              query = p.name;
              showResults(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Text('🔍', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 32),
          Text(
            'NO MATCHES FOUND',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.textHeading,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any products for "$query"',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}


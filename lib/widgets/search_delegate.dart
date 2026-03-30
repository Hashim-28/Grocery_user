import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_data.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';

class ProductSearchDelegate extends SearchDelegate {
  final AppState appState;
  ProductSearchDelegate({required this.appState});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: AppTheme.textDark),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = AppData.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              'No products found for "$query"',
              style: GoogleFonts.outfit(
                color: AppTheme.textMedium,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) => ProductCard(
        product: results[i],
        appState: appState,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = AppData.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: suggestions[i].imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(suggestions[i].imageUrl!, fit: BoxFit.cover),
                )
              : Center(child: Text(suggestions[i].emoji, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(
          suggestions[i].name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Text(
          '₨${suggestions[i].price.toInt()} · ${suggestions[i].category}',
          style: GoogleFonts.outfit(color: AppTheme.textLight, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          query = suggestions[i].name;
          showResults(context);
        },
      ),
    );
  }
}

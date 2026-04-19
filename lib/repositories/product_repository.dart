import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProductRepository {
  final _client = Supabase.instance.client;

  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      final List data = (response as List?) ?? [];
      return data.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      final List data = (response as List?) ?? [];
      return data.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class CategoryRepository {
  final _client = Supabase.instance.client;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);
      
      final List data = (response as List?) ?? [];
      
      // If categories are empty in DB, we could return a default set or empty list
      return data.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}

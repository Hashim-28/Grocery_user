import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deal_model.dart';

class DealRepository {
  final _client = Supabase.instance.client;

  Future<List<Deal>> getActiveDeals() async {
    try {
      final response = await _client
          .from('deals')
          .select('*, deal_items(*, products(*))')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      final List data = (response as List?) ?? [];
      
      // Filter out handles expired deals if needed, 
      // but usually the DB or Admin handles it.
      return data
          .map((item) => Deal.fromJson(item as Map<String, dynamic>))
          .where((deal) => !deal.isExpired)
          .toList();
    } catch (e) {
      print('Error fetching active deals: $e');
      return [];
    }
  }
}

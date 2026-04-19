import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AddressRepository {
  final SupabaseClient _supabase;

  AddressRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Address>> fetchAddresses() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List data = response as List? ?? [];
      return data
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      return [];
    }
  }

  Future<Address?> addAddress(Address address) async {
    try {
      final response = await _supabase
          .from('addresses')
          .insert(address.toJson())
          .select()
          .single();
      return Address.fromJson(response);
    } catch (e) {
      debugPrint('Error adding address: $e');
      return null;
    }
  }

  Future<Address?> updateAddress(Address address) async {
    try {
      final response = await _supabase
          .from('addresses')
          .update(address.toJson())
          .eq('id', address.id)
          .select()
          .single();
      return Address.fromJson(response);
    } catch (e) {
      debugPrint('Error updating address: $e');
      return null;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await _supabase.from('addresses').delete().eq('id', addressId);
      return true;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // First, set all user's addresses to is_default = false
      await _supabase
          .from('addresses')
          .update({'is_default': false}).eq('user_id', user.id);

      // Then, set the specific address to is_default = true
      await _supabase
          .from('addresses')
          .update({'is_default': true}).eq('id', addressId);

      return true;
    } catch (e) {
      debugPrint('Error setting default address: $e');
      return false;
    }
  }
}

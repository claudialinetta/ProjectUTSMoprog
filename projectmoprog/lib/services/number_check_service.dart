import 'package:supabase_flutter/supabase_flutter.dart';

class NumberCheckService {
  final SupabaseClient _db = Supabase.instance.client;

  static String toPhoneKey(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    }

    return digits;
  }

  Future<void> record({
    required String ownerId,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final phoneKey = toPhoneKey(phoneNumber);

      final result = await _db.from('number_checks').insert({
        'owner_id': ownerId,
        'name': name,
        'phone_number': phoneNumber,
        'phone_key': phoneKey,
        'checked_at': DateTime.now().toUtc().toIso8601String(),
      }).select();

      print('NUMBER CHECK SAVED: $result');
    } catch (e) {
      print('===== NUMBER CHECK ERROR =====');
      print(e);
      rethrow;
    }
  }

  Future<int> getCheckedCount(String ownerId) async {
    try {
      return await _db
          .from('number_checks')
          .count(CountOption.exact)
          .eq('owner_id', ownerId);
    } catch (e) {
      print('Failed to get checked count: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentChecks(
    String ownerId, {
    int limit = 10,
  }) async {
    try {
      final response = await _db
          .from('number_checks')
          .select()
          .eq('owner_id', ownerId)
          .order('checked_at', ascending: false)
          .limit(limit);

      return response
          .map<Map<String, dynamic>>((row) => Map<String, dynamic>.from(row))
          .toList();
    } catch (e) {
      print('Failed to get recent checks: $e');
      rethrow;
    }
  }
}

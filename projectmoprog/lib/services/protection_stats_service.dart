import 'package:projectmoprog/models/call_history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/protection_stats.dart';

class ProtectionStatsService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<ProtectionStats> getStats(String ownerId) async {
    final checkedCount = await _db
        .from('number_checks')
        .count(CountOption.exact)
        .eq('owner_id', ownerId);

    final spamCount = await _db
        .from('call_history')
        .count(CountOption.exact)
        .eq('owner_id', ownerId)
        .eq('status', 'spam');

    var reportsCount = 0;

    try {
      reportsCount = await _db
          .from('contact_reports')
          .count(CountOption.exact)
          .eq('owner_id', ownerId);
    } catch (e) {
      reportsCount = 0;
    }

    return ProtectionStats(
      numbersChecked: checkedCount,
      spamAvoided: spamCount,
      reportsGiven: reportsCount,
    );
  }

  Future<List<ProtectionActivity>> getRecentActivity(String ownerId) async {
    try {
      final rows = await _db
          .from('notifications')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false)
          .limit(5);

      return rows
          .map<ProtectionActivity>(
            (row) => ProtectionActivity.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentChecks(
    String ownerId, {
    int limit = 10,
  }) async {
    final response = await _db
        .from('number_checks')
        .select()
        .eq('owner_id', ownerId)
        .order('checked_at', ascending: false)
        .limit(limit);

    return response
        .map<Map<String, dynamic>>((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<List<CallHistoryModel>> getRecentCalls(
    String ownerId, {
    int limit = 10,
  }) async {
    final response = await _db
        .from('call_history')
        .select()
        .eq('owner_id', ownerId)
        .order('happened_at', ascending: false)
        .limit(limit);

    return response
        .map<CallHistoryModel>(
          (row) => CallHistoryModel.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }
}

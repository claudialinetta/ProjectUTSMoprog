import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/protection_stats.dart';

import 'package:flutter/foundation.dart';

class ProtectionStatsService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<ProtectionStats> getStats(String ownerId) async {
    final checkedCount = await _db
        .from('number_checks')
        .count(CountOption.exact)
        .eq('owner_id', ownerId);

    final spamCount = await _db
        .from('number_checks')
        .count(CountOption.exact)
        .eq('owner_id', ownerId)
        .eq('is_spam', true);

    var reportsCount = 0;
    try {
      reportsCount = await _db
          .from('contact_reports')
          .count(CountOption.exact)
          .eq('owner_id', ownerId);
    } catch (e) {
      debugPrint('Failed to count reports: $e');
      reportsCount = 0;
    }

    return ProtectionStats(
      numbersChecked: checkedCount,
      spamAvoided: spamCount,
      reportsGiven: reportsCount,
    );
  }

  Future<List<CheckEntry>> getCheckedHistory(String ownerId) async {
    final rows = await _db
        .from('number_checks')
        .select()
        .eq('owner_id', ownerId)
        .order('checked_at', ascending: false)
        .limit(30);

    return rows
        .map<CheckEntry>(
          (row) => CheckEntry.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<List<CheckEntry>> getSpamHistory(String ownerId) async {
    final rows = await _db
        .from('number_checks')
        .select()
        .eq('owner_id', ownerId)
        .eq('is_spam', true)
        .order('checked_at', ascending: false)
        .limit(10);

    return rows
        .map<CheckEntry>(
          (row) => CheckEntry.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<List<ReportHistoryEntry>> getReportHistory(String ownerId) async {
    try {
      final rows = await _db
          .from('contact_reports')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false)
          .limit(30);

      return rows
          .map<ReportHistoryEntry>(
            (row) => ReportHistoryEntry.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DailyActivity>> getWeeklyActivity(String ownerId) async {
    final today = DateTime.now();
    final since = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));

    final rows = await _db
        .from('number_checks')
        .select('checked_at')
        .eq('owner_id', ownerId)
        .gte('checked_at', since.toUtc().toIso8601String());

    final counts = <String, int>{};
    for (final row in rows) {
      final dt = DateTime.parse(row['checked_at'].toString()).toLocal();
      final key = '${dt.year}-${dt.month}-${dt.day}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return List.generate(7, (i) {
      final day = since.add(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      return DailyActivity(day: day, count: counts[key] ?? 0);
    });
  }
}

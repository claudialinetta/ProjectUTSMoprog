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

  Future<List<Map<String, dynamic>>> getCheckActivity(
    String ownerId, {
    int days = 7,
  }) async {
    final now = DateTime.now();

    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    final response = await _db
        .from('number_checks')
        .select('checked_at')
        .eq('owner_id', ownerId)
        .gte('checked_at', startDate.toUtc().toIso8601String())
        .order('checked_at', ascending: true);

    final Map<String, int> dailyCounts = {};

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final key = _dateKey(date);

      dailyCounts[key] = 0;
    }

    for (final row in response) {
      final checkedAt = DateTime.parse(row['checked_at'].toString()).toLocal();

      final key = _dateKey(checkedAt);

      if (dailyCounts.containsKey(key)) {
        dailyCounts[key] = dailyCounts[key]! + 1;
      }
    }

    return dailyCounts.entries.map((entry) {
      final date = DateTime.parse(entry.key);

      return {'date': date, 'count': entry.value};
    }).toList();
  }

  Future<Map<String, dynamic>> getProtectionInsights(String ownerId) async {
    final rows = await _db
        .from('number_checks')
        .select('name, phone_number, checked_at')
        .eq('owner_id', ownerId)
        .order('checked_at', ascending: false);

    if (rows.isEmpty) {
      return {
        'activeDays': 0,
        'busiestDay': null,
        'busiestDayCount': 0,
        'averagePerDay': 0.0,
        'mostCheckedNumber': null,
        'mostCheckedCount': 0,
      };
    }

    final Map<String, int> dayCounts = {};
    final Map<String, int> numberCounts = {};
    final Map<String, String> numberNames = {};

    for (final row in rows) {
      final checkedAt = DateTime.parse(row['checked_at'].toString()).toLocal();

      final dayKey = _dateKey(checkedAt);

      dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;

      final phone = row['phone_number']?.toString() ?? '';
      final name = row['name']?.toString() ?? 'Unknown';

      if (phone.isNotEmpty) {
        numberCounts[phone] = (numberCounts[phone] ?? 0) + 1;
        numberNames[phone] = name;
      }
    }

    String? busiestDay;
    int busiestDayCount = 0;

    for (final entry in dayCounts.entries) {
      if (entry.value > busiestDayCount) {
        busiestDay = entry.key;
        busiestDayCount = entry.value;
      }
    }

    String? mostCheckedNumber;
    int mostCheckedCount = 0;

    for (final entry in numberCounts.entries) {
      if (entry.value > mostCheckedCount) {
        mostCheckedNumber = entry.key;
        mostCheckedCount = entry.value;
      }
    }

    final activeDays = dayCounts.length;

    final averagePerDay = activeDays == 0 ? 0.0 : rows.length / activeDays;

    return {
      'activeDays': activeDays,
      'busiestDay': busiestDay,
      'busiestDayCount': busiestDayCount,
      'averagePerDay': averagePerDay,
      'mostCheckedNumber': mostCheckedNumber,
      'mostCheckedName': mostCheckedNumber == null
          ? null
          : numberNames[mostCheckedNumber],
      'mostCheckedCount': mostCheckedCount,
    };
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

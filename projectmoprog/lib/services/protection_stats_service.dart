import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/protection_stats.dart';

class ProtectionStatsService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<ProtectionStats> getStats(String ownerId) async {
    final checkedCount = await _db
        .from('call_history')
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
          .from('reports')
          .count(CountOption.exact)
          .eq('reporter_id', ownerId);
    } catch (e): print('Report count error: $e'); {
      reportsCount = 0;
    }

    return ProtectionStats(
      numbersChecked: checkedCount,
      spamAvoided: spamCount,
      reportsGiven: reportsCount,
    );
  }
}

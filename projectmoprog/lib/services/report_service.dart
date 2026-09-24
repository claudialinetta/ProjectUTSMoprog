import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<bool> submitReport({
    required String ownerId,
    required int contactId,
  }) async {
    try {
      await _db.from('contact_reports').insert({
        'owner_id': ownerId,
        'contact_id': contactId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') return false;
      rethrow;
    }

    await _db.rpc('increment_report_count', params: {'target_id': contactId});
    return true;
  }
}

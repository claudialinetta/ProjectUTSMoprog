import 'package:supabase_flutter/supabase_flutter.dart';

class SupportService {
  static const String _table = 'support_tickets';

  final SupabaseClient _db = Supabase.instance.client;

  Future<void> submitTicket({
    required String subject,
    required String category,
    required String description,
  }) async {
    await _db.from(_table).insert({
      'subject': subject,
      'category': category,
      'description': description,
    });
  }
}

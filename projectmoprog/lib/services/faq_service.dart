import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/faq_item.dart';

class FaqService {
  static const String _table = 'faq';

  final SupabaseClient _db = Supabase.instance.client;

  Future<List<FaqItem>> getFaqs() async {
    final rows = await _db
        .from(_table)
        .select()
        .order('category')
        .order('sort_order');

    return rows
        .map<FaqItem>((row) => FaqItem.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }
}

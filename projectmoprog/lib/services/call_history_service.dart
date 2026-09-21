import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/call_history_model.dart';

class CallHistoryService {
  static const String _table = 'call_history';

  final SupabaseClient _db = Supabase.instance.client;

  static String toPhoneKey(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    }
    return digits;
  }

  Future<List<CallHistoryModel>> getHistory(String ownerId) async {
    final rows = await _db
        .from(_table)
        .select()
        .eq('owner_id', ownerId)
        .order('happened_at', ascending: false);

    return rows
        .map<CallHistoryModel>(
          (row) => CallHistoryModel.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<void> record({
    required String ownerId,
    required String name,
    required String phoneNumber,
    CallStatus status = CallStatus.unknown,
    CallType type = CallType.searched,
    DateTime? happenedAt,
  }) async {
    try {
      await _db.from(_table).upsert({
        'owner_id': ownerId,
        'name': name,
        'phone_number': phoneNumber,
        'phone_key': toPhoneKey(phoneNumber),
        'status': status.name,
        'call_type': type.name,
        'happened_at': (happenedAt ?? DateTime.now()).toUtc().toIso8601String(),
      }, onConflict: 'owner_id,phone_key');
    } catch (e) {
      debugPrint('Gagal mencatat riwayat: $e');
    }
  }

  Future<void> restore(CallHistoryModel item) {
    return record(
      ownerId: item.ownerId,
      name: item.name,
      phoneNumber: item.phoneNumber,
      status: item.status,
      type: item.type,
      happenedAt: item.happenedAt,
    );
  }

  Future<void> delete(String id) async {
    await _db.from(_table).delete().eq('id', id);
  }

  Future<void> clearAll(String ownerId) async {
    await _db.from(_table).delete().eq('owner_id', ownerId);
  }
}

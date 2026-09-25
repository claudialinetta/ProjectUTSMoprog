import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/call_history_model.dart';
import '../models/contact_tag.dart';
import 'notification_service.dart';

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
    List<ContactTag> initialTags = const [],
  }) async {
    try {
      final phoneKey = toPhoneKey(phoneNumber);

      final countResponse = await _db
          .from(_table)
          .select('id')
          .eq('owner_id', ownerId)
          .eq('phone_key', phoneKey)
          .count(CountOption.exact);

      final int previousCallCount = countResponse.count;

      CallStatus finalStatus = status;
      List<ContactTag> finalTags = List.from(initialTags);

      bool isUnknown = name == 'Unknown Caller' || name == phoneNumber;

      if (isUnknown && previousCallCount >= 4) {
        finalStatus = CallStatus.spam;

        final hasSpamTag = finalTags.any(
          (t) => t.label.toLowerCase().contains('spam'),
        );
        if (!hasSpamTag) {
          finalTags.add(
            ContactTag(label: 'Spam', addedByName: 'Automated system'),
          );
        }
      } else {
        final hasSpamTag = finalTags.any(
          (t) => t.label.toLowerCase().contains('spam'),
        );
        if (hasSpamTag) finalStatus = CallStatus.spam;
      }

      await _db.from(_table).upsert({
        'owner_id': ownerId,
        'name': name,
        'phone_number': phoneNumber,
        'phone_key': toPhoneKey(phoneNumber),
        'status': finalStatus.name,
        'call_type': type.name,
        'happened_at': (happenedAt ?? DateTime.now()).toUtc().toIso8601String(),
        'tags': finalTags.map((t) => t.toJson()).toList(),
      }, onConflict: 'owner_id,phone_key');

      final notificationService = NotificationService();

      if (type == CallType.missed) {
        await notificationService.createNotification(
          ownerId: ownerId,
          title: 'Missed Call',
          message: 'Unanswered call from $phoneNumber',
          type: 'missed_call',
        );
      }

      if (isUnknown && previousCallCount == 4) {
        await notificationService.createNotification(
          ownerId: ownerId,
          title: 'Spam Alert',
          message: 'Unknown number ($phoneNumber) has called you 5 times.',
          type: 'spam_warning',
        );
      }
    } catch (e) {
      debugPrint('Failed to check history: $e');
      rethrow;
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

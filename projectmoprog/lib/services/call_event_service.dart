import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CallEventService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<Map<String, dynamic>?> findUserByPhone(String phoneNumber) async {
    try {
      final normalizedPhone = _normalizePhone(phoneNumber);

      final users = await _db.from('users').select('id, name, phone_number');

      for (final user in users) {
        final userPhone = user['phone_number']?.toString() ?? '';

        if (_normalizePhone(userPhone) == normalizedPhone) {
          return {
            'id': user['id'].toString(),
            'name': user['name']?.toString() ?? 'GetContact User',
            'phoneNumber': userPhone,
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('Failed to find user by phone: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser(String userId) async {
    try {
      final response = await _db
          .from('users')
          .select('id, name, phone_number')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return {
        'id': response['id'],
        'name': response['name'],
        'phoneNumber': response['phone_number'],
      };
    } catch (e) {
      debugPrint('Failed to get current user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCall({
    required String callerId,
    required String receiverId,
    required String callerName,
    required String callerPhone,
  }) async {
    try {
      final response = await _db
          .from('call_events')
          .insert({
            'caller_id': callerId,
            'receiver_id': receiverId,
            'caller_name': callerName,
            'caller_phone': callerPhone,
            'status': 'ringing',
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Failed to create call: $e');
      rethrow;
    }
  }

  Future<void> acceptCall(String callId) async {
    await _db
        .from('call_events')
        .update({
          'status': 'accepted',
          'connected_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callId)
        .eq('status', 'ringing');
  }

  Future<void> declineCall(String callId) async {
    await _db
        .from('call_events')
        .update({
          'status': 'declined',
          'ended_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callId)
        .eq('status', 'ringing');
  }

  Future<void> cancelCall(String callId) async {
    await _db
        .from('call_events')
        .update({
          'status': 'cancelled',
          'ended_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callId)
        .eq('status', 'ringing');
  }

  Future<void> endCall({
    required String callId,
    required int durationSeconds,
  }) async {
    await _db
        .from('call_events')
        .update({
          'status': 'ended',
          'ended_at': DateTime.now().toUtc().toIso8601String(),
          'duration_seconds': durationSeconds,
        })
        .eq('id', callId)
        .eq('status', 'accepted');
  }

  String _normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    }

    return digits;
  }
}

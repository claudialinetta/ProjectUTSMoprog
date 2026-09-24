import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String _table = 'notifications';
  final SupabaseClient _db = Supabase.instance.client;

  Future<void> createNotification({
    required String ownerId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _db.from(_table).insert({
        'owner_id': ownerId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to make notification: $e');
    }
  }

  Future<List<NotificationModel>> getNotifications(String ownerId) async {
    try {
      final rows = await _db
          .from(_table)
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return rows.map((row) => NotificationModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Failed to make notification: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.from(_table).update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      debugPrint('Fail to read status: $e');
    }
  }

  Future<int> getUnreadCount(String ownerId) async {
    try {
      final response = await _db
          .from(_table)
          .select('id')
          .eq('owner_id', ownerId)
          .eq('is_read', false)
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAllAsRead(String ownerId) async {
    try {
      await _db.from(_table).update({'is_read': true}).eq('owner_id', ownerId);
    } catch (e) {
      debugPrint('Failed to read all: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _db.from(_table).delete().eq('id', id);
    } catch (e) {
      debugPrint('Fail to delete notification: $e');
    }
  }
}
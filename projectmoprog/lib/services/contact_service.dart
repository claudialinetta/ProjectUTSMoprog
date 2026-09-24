import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contact_model.dart';
import 'notification_service.dart';

class ContactService {
  final _supabase = Supabase.instance.client;

  Future<List<ContactModel>> getContacts(String currentUserId) async {
    try {
      final response = await _supabase
          .from('contacts')
          .select()
          .eq('ownerId', currentUserId);
      return response
          .map((dynamic item) => ContactModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load contacts from Supabase: $e');
    }
  }

  Future<bool> reportContact({
    required String contactId,
    required int currentCount,
    required String reporterId,
  }) async {
    try {
      await _supabase.from('contact_reports').insert({
        'owner_id': reporterId,
        'contact_id': int.parse(contactId),
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') return false; // already reported before
      throw Exception('Failed to log report: $e');
    }

    try {
      await _supabase
          .from('contacts')
          .update({'reportCount': currentCount + 1})
          .eq('id', contactId);
    } catch (e) {
      throw Exception('Failed to update report count: $e');
    }

    return true;
  }

  Future<List<String>> getMySavedNames(String myPhoneNumber) async {
    final response = await Supabase.instance.client
        .from('savedContacts')
        .select('savedName')
        .eq('savedPhoneNumber', myPhoneNumber);
    final List<String> savedNames = response
        .map((data) => data['savedName'] as String)
        .toList();
    return savedNames.toSet().toList();
  }

  Future<void> checkNewJoinedContacts(String currentUserId) async {
    try {
      final contacts = await getContacts(currentUserId);
      if (contacts.isEmpty) return;

      final existingNotifs = await _supabase
          .from('notifications')
          .select('message')
          .eq('owner_id', currentUserId)
          .eq('type', 'new_contact');
      final existingMessages = existingNotifs
          .map((n) => n['message'].toString())
          .toList();
      final notificationService = NotificationService();

      for (var contact in contacts) {
        final phone = contact.phoneNumber;
        final name = contact.name;
        final expectedMessage = '$name ($phone) joined Getcontact Clone';

        if (!existingMessages.contains(expectedMessage)) {
          await notificationService.createNotification(
            ownerId: currentUserId,
            title: 'New Contact Joined!',
            message: expectedMessage,
            type: 'new_contact',
          );
        }
      }
    } catch (e) {
      debugPrint('Failed new contact joined: $e');
    }
  }
}

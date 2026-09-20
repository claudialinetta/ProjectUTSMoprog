import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact_model.dart';

class ContactService {
  final _supabase = Supabase.instance.client;

  Future<List<ContactModel>> getContacts(String currentUserId) async {
    try {
      final response = await _supabase.from('contacts').select().eq('ownerId', currentUserId);
      return response.map((dynamic item) => ContactModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load contacts from Supabase: $e');
    }
  }

  Future<List<String>> getMySavedNames(String myPhoneNumber) async {
    final response = await Supabase.instance.client
      .from('savedContacts')
      .select('savedName')
      .eq('savedPhoneNumber', myPhoneNumber);
    final List<String> savedNames = response.map((data) => data['savedName'] as String).toList();
    return savedNames.toSet().toList(); 
  }
}


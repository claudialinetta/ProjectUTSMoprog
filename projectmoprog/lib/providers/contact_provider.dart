import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _service = ContactService();
  final _supabase = Supabase.instance.client;

  List<ContactModel> _allContacts = [];
  List<ContactModel> _filteredContacts = [];
  bool _isLoading = false;
  String _selectedTag = 'All';
  String _searchQuery = '';

  List<ContactModel> get filteredContacts => _filteredContacts;
  List<ContactModel> get allContacts => _allContacts;
  bool get isLoading => _isLoading;
  String get selectedTag => _selectedTag;

  List<String> get availableTags {
    final tags = <String>{};
    for (var contact in _allContacts) {
      if (contact.tag.isNotEmpty && contact.tag != '-') {
        tags.add(contact.tag);
      }
      if (contact.tags.isNotEmpty) {
        tags.addAll(contact.tags.map((t) => t.label));
      }
    }
    final sortedTags = tags.toList()..sort();
    return ['All', ...sortedTags];
  }

  Future<void> fetchContacts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final contacts = await _service.getContacts(userId);
      contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      _allContacts = contacts;
      _applyFilters();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(String userId, String name, String phone) async {
    _isLoading = true;
    notifyListeners();

    String newInitial = '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isNotEmpty && words[0].isNotEmpty) {
      if (words.length == 1) {
        newInitial = words[0][0].toUpperCase();
      } else {
        newInitial = (words[0][0] + words[1][0]).toUpperCase();
      }
    }

    try {
      await _supabase.from('contacts').insert({
        'name': name,
        'phoneNumber': phone,
        'ownerId': userId,
        'tag': 'Unknown',
        'reportCount': 0,
        'avatarInitial': newInitial,
      });
      await fetchContacts(userId); 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateContact(String contactId, String newName, String newPhone, String userId) async {
    try {
      await _supabase.from('contacts').update({
        'name': newName,
        'phoneNumber': newPhone,
        'avatarInitial': newName.isNotEmpty ? newName[0].toUpperCase() : '?',
      }).eq('id', contactId);
      
      await fetchContacts(userId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteContact(String contactId, String userId) async {
    try {
      await _supabase.from('contacts').delete().eq('id', contactId);
      await fetchContacts(userId);
    } catch (e) {
      throw e;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedTag(String tag) {
    _selectedTag = tag;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-]'), '');

    _filteredContacts = _allContacts.where((contact) {
      final nameMatch = contact.name.toLowerCase().contains(query);
      final cleanPhone = contact.phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');
      final phoneMatch = cleanPhone.contains(cleanQuery);
      final searchMatch = nameMatch || phoneMatch;

      bool tagMatch = _selectedTag == 'All';
      if (_selectedTag != 'All') {
        tagMatch = (contact.tag.toLowerCase() == _selectedTag.toLowerCase()) || 
                   contact.tags.any((t) => t.label.toLowerCase() == _selectedTag.toLowerCase());
      }

      return searchMatch && tagMatch;
    }).toList();
  }
}
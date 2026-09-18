import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../widgets/contact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ContactService _service = ContactService();
  final TextEditingController _searchController = TextEditingController();
  List<ContactModel> _allContacts = [];
  List<ContactModel> _filteredContacts = [];
  bool _isLoading = true;
  String _selectedTag = 'All';
  final List<String> _availableTags = ['All', 'Trusted', 'Spam Likely', 'Unknown'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final contacts = await _service.getContacts();
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false; 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-]'), '');
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final nameMatch = contact.name.toLowerCase().contains(query);
        final cleanPhone = contact.phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');
        final phoneMatch = cleanPhone.contains(cleanQuery);
        final textMatch = nameMatch || phoneMatch;
        final tagMatch = _selectedTag == 'All' || contact.tag == _selectedTag;
        return textMatch && tagMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GetContact Clone"),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterContacts(),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableTags.length,
                    itemBuilder: (context, index) {
                      final tag = _availableTags[index];
                      final isSelected = _selectedTag == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(tag == 'All' ? 'All' : tag),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = tag;
                            });
                            _filterContacts();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredContacts.isEmpty ? const Center(child: Text("Contact not Found!")) : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) =>
                ContactCard(contact: _filteredContacts[index]),
            ),
          ),
        ],
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final contacts = await _service.getContacts();
    setState(() {
      _allContacts = contacts;
      _filteredContacts = contacts;
      _isLoading = false;
    });
  }

  void _filterContacts(String query) {
    List<ContactModel> results = [];
    if (query.isEmpty) {
      results = _allContacts;
    } else {
      results = _allContacts.where((contact) {
        final nameMatch = contact.name.toLowerCase().contains(query.toLowerCase());
        final phoneMatch = contact.phoneNumber.contains(query);
        return nameMatch || phoneMatch;
      }).toList();
    }

    setState(() {
      _filteredContacts = results;
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
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
          ),
          Expanded(
            child: _filteredContacts.isEmpty ? const Center(child: Text("Contact not found")) : ListView.builder(
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

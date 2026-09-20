import 'package:flutter/material.dart';

import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import '../../widgets/contact_card.dart';

class ContactScreen extends StatefulWidget {
  final String currentUserId;

  const ContactScreen({super.key, required this.currentUserId});

  @override
  State<ContactScreen> createState() => _ContactScreenState();  
}

class _ContactScreenState extends State<ContactScreen> {
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
    try {
      final contacts = await _service.getContacts(widget.currentUserId);

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-]'), '');

    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final nameMatch = contact.name.toLowerCase().contains(query);

        final cleanPhone = contact.phoneNumber.replaceAll(
          RegExp(r'[\s\-]'),
          '',
        );

        final phoneMatch = cleanPhone.contains(cleanQuery);

        return nameMatch || phoneMatch;
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
      appBar: AppBar(title: const Text("My Contacts")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
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
                ),
                Expanded(
                  child: _filteredContacts.isEmpty
                      ? const Center(child: Text("Contact not Found!"))
                      : ListView.builder(
                          itemCount: _filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = _filteredContacts[index];

                            return ContactCard(contact: contact);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
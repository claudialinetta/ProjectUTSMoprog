import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import '../../widgets/contact_card.dart';
import 'contact_detail_screen.dart';

class ContactScreen extends StatefulWidget {
  final String currentUserId;

  const ContactScreen({super.key, required this.currentUserId});

  @override
  State<ContactScreen> createState() => _ContactScreenState();  
}

class _ContactScreenState extends State<ContactScreen> {
  final ContactService _service = ContactService();
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Set<String> _reportedContacts = {};

  List<ContactModel> _allContacts = [];
  List<ContactModel> _filteredContacts = [];
  bool _isLoading = true;

  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  List<String> get _availableTags {
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

  Future<void> _fetchData() async {
    try {
      final contacts = await _service.getContacts(widget.currentUserId);
      contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
        _selectedTag = 'All';
      });
      _filterContacts();
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

  Future<void> _saveNewContact(BuildContext bottomSheetContext) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Phone Number cannot be empty.')),
      );
      return;
    }

    Navigator.pop(bottomSheetContext);
    setState(() => _isLoading = true);

    try {
      await _supabase.from('contacts').insert({
        'name': name,
        'phoneNumber': phone,
        'ownerId': widget.currentUserId,
        'tag': 'Unknown',
        'reportCount': 0,
        'avatarInitial': name.isNotEmpty ? name[0].toUpperCase() : '?',
      });

      _nameController.clear();
      _phoneController.clear();

      await _fetchData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add contact: $e'), backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),),
        );
      }
    }
  }

  void _showAddContactForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+62 812-3456-7890',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _saveNewContact(context),
                child: const Text('Save Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-]'), '');

    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final nameMatch = contact.name.toLowerCase().contains(query);
        final cleanPhone = contact.phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');
        final phoneMatch = cleanPhone.contains(cleanQuery);
        final searchMatch = nameMatch || phoneMatch;

        bool tagMatch = _selectedTag== 'All' || contact.tags.any((t) => t.label == _selectedTag);
        
        if (_selectedTag != 'All') {
          tagMatch = (contact.tag.toLowerCase() == _selectedTag.toLowerCase()) || contact.tags.any((t) => t.label.toLowerCase() == _selectedTag.toLowerCase());
        }

        return searchMatch && tagMatch;
      }).toList();
    });
  }

  Future<void> _handleReport(ContactModel contact, String reason) async {
    if (_reportedContacts.contains(contact.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You've already reported this contact."),
          backgroundColor: Colors.orange,
        ),
      );
      return; 
    }

    try {
      await _service.reportContact(contact.id, contact.reportCount);

      setState(() {
        _reportedContacts.add(contact.id); 
        contact.reportCount += 1; 
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${contact.phoneNumber} was reported as '$reason'"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to report the contact. Please check your internet connection."),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactForm,
        backgroundColor: Colors.blue.shade600,
        tooltip: 'Add Contact',
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                if (_allContacts.isNotEmpty)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableTags.length,
                      itemBuilder: (context, index) {
                        final tag = _availableTags[index];
                        final isSelected = _selectedTag == tag;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: Colors.blue.shade100,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.blue.shade900 : Colors.black87,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedTag = selected ? tag : 'All';
                              });
                              _filterContacts();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: _filteredContacts.isEmpty
                      ? const Center(child: Text("Contact not Found!"))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                          itemCount: _filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = _filteredContacts[index];
                            final currentLetter = contact.name.isNotEmpty 
                                ? contact.name[0].toUpperCase() 
                                : '?';
                            final previousLetter = index > 0
                                ? (_filteredContacts[index - 1].name.isNotEmpty
                                    ? _filteredContacts[index - 1].name[0].toUpperCase()
                                    : '?')
                                : '';
                            final bool showHeader = currentLetter != previousLetter;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          currentLetter,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContactDetailScreen(
                                          contact: contact,
                                          currentUserId: widget.currentUserId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ContactCard(
                                    contact: contact,
                                    onReport: (reason) => _handleReport(contact, reason),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ContactDetailScreen(
                                            contact: contact,
                                            currentUserId: widget.currentUserId,
                                          ),
                                        ),
                                      );
                                      _fetchData(); 
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty || digits == '62' || digits == '0') {
      return const TextEditingValue(text: '');
    }

    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    } else if (!digits.startsWith('62')) {
      digits = '62$digits';
    }

    String formatted = '+';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) {
        formatted += ' ';
      }
      else if (i == 5) {
        formatted += '-';
      }
      else if (i == 9) {
        formatted += '-';
      }
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
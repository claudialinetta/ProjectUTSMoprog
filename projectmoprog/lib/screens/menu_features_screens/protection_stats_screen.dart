import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import '../../widgets/contact_card.dart';
import 'contact_detail_screen.dart';
import '../../providers/contact_provider.dart';

class ContactScreen extends StatefulWidget {
  final String currentUserId;

  const ContactScreen({super.key, required this.currentUserId});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ContactService _service = ContactService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactProvider>(
        context,
        listen: false,
      ).fetchContacts(widget.currentUserId);
    });
  }

  Future<void> _saveNewContact(
    BuildContext bottomSheetContext,
    ContactProvider provider,
  ) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and Phone Number cannot be empty.'),
        ),
      );
      return;
    }

    Navigator.pop(bottomSheetContext);

    try {
      await provider.addContact(
        widget.currentUserId,
        name,
        phone,
      );

      _nameController.clear();
      _phoneController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add contact: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showAddContactForm(ContactProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _saveNewContact(
                  context,
                  provider,
                ),
                child: const Text(
                  'Save Contact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleReport(
    ContactModel contact,
    String reason,
  ) async {
    try {
      final success = await _service.reportContact(
        contactId: contact.id,
        currentCount: contact.reportCount,
        reporterId: widget.currentUserId,
        reason: reason,
        contactName: contact.name,
        phoneNumber: contact.phoneNumber,
      );

      if (!success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You've already reported this contact.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        contact.reportCount += 1;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${contact.phoneNumber} was reported as '$reason'",
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Report failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("My Contacts"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddContactForm(provider),
            backgroundColor: Colors.blue.shade600,
            tooltip: 'Add Contact',
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          provider.setSearchQuery(value);
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Search by name or phone number...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),

                    if (provider.allContacts.isNotEmpty)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.availableTags.length,
                          itemBuilder: (context, index) {
                            final tag =
                                provider.availableTags[index];

                            final isSelected =
                                provider.selectedTag == tag;

                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                              ),
                              child: ChoiceChip(
                                label: Text(tag),
                                selected: isSelected,
                                selectedColor:
                                    Colors.blue.shade100,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.blue.shade900
                                      : Colors.black87,
                                ),
                                onSelected: (selected) {
                                  provider.setSelectedTag(
                                    selected ? tag : 'All',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    Expanded(
                      child: provider.filteredContacts.isEmpty
                          ? const Center(
                              child: Text(
                                "Contact not Found!",
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                0,
                                0,
                                0,
                                100,
                              ),
                              itemCount:
                                  provider.filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact =
                                    provider.filteredContacts[index];

                                final currentLetter =
                                    contact.name.isNotEmpty
                                        ? contact.name[0]
                                            .toUpperCase()
                                        : '?';

                                final previousLetter =
                                    index > 0
                                        ? (provider
                                                .filteredContacts[
                                                    index - 1]
                                                .name
                                                .isNotEmpty
                                            ? provider
                                                .filteredContacts[
                                                    index - 1]
                                                .name[0]
                                                .toUpperCase()
                                            : '?')
                                        : '';

                                final bool showHeader =
                                    currentLetter !=
                                        previousLetter;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (showHeader) ...[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          top: 16.0,
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              currentLetter,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Colors
                                                    .blue
                                                    .shade800,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors
                                                    .grey
                                                    .shade300,
                                                thickness: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    ContactCard(
                                      contact: contact,
                                      onReport: (reason) =>
                                          _handleReport(
                                        contact,
                                        reason,
                                      ),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ContactDetailScreen(
                                              contact: contact,
                                              currentUserId:
                                                  widget.currentUserId,
                                            ),
                                          ),
                                        );

                                        if (mounted) {
                                          Provider.of<
                                              ContactProvider>(
                                            context,
                                            listen: false,
                                          ).fetchContacts(
                                            widget.currentUserId,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits =
        newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty ||
        digits == '62' ||
        digits == '0') {
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
      } else if (i == 5) {
        formatted += '-';
      } else if (i == 9) {
        formatted += '-';
      }

      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}
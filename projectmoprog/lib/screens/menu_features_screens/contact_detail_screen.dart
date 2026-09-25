import 'package:flutter/material.dart';
import 'package:projectmoprog/models/contact_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/number_check_service.dart';
import '../chat_screens/chat_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final ContactModel contact;
  final String currentUserId;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.currentUserId,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final _supabase = Supabase.instance.client;

  late ContactModel _currentContact;

  @override
  void initState() {
    super.initState();
    _currentContact = widget.contact;

    print('OPENING CONTACT DETAIL');
    print('currentUserId: ${widget.currentUserId}');
    print('contact: ${_currentContact.name}');
    print('phone: ${_currentContact.phoneNumber}');

    _recordCheck();
  }

  Future<void> _recordCheck() async {
    try {
      await NumberCheckService().record(
        ownerId: widget.currentUserId,
        name: _currentContact.name,
        phoneNumber: _currentContact.phoneNumber,
      );

      print('CHECK SUCCESS');
    } catch (e) {
      print('CHECK FAILED: $e');
    }
  }

  Future<void> _deleteContact() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('contacts').delete().eq('id', _currentContact.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete contact: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showEditForm() {
    final nameController = TextEditingController(text: _currentContact.name);
    final phoneController = TextEditingController(
      text: _currentContact.phoneNumber,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
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
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newPhone = phoneController.text.trim();
                  if (newName.isEmpty || newPhone.isEmpty) return;

                  Navigator.pop(bottomSheetContext);

                  try {
                    await _supabase
                        .from('contacts')
                        .update({
                          'name': newName,
                          'phoneNumber': newPhone,
                          'avatarInitial': newName.isNotEmpty
                              ? newName[0].toUpperCase()
                              : '?',
                        })
                        .eq('id', _currentContact.id);

                    setState(() {
                      _currentContact = ContactModel(
                        id: _currentContact.id,
                        name: newName,
                        phoneNumber: newPhone,
                        tag: _currentContact.tag,
                        reportCount: _currentContact.reportCount,
                        avatarInitial: newName.isNotEmpty
                            ? newName[0].toUpperCase()
                            : '?',
                        tags: _currentContact.tags,
                        ownerId: _currentContact.ownerId,
                      );
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Update Contact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.grey),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                _currentContact.avatarInitial,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _currentContact.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _currentContact.phoneNumber,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          contact: _currentContact,
                          currentUserId: widget.currentUserId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 32),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: Colors.orange.shade700,
                  onTap: _showEditForm,
                ),
                const SizedBox(width: 32),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: _deleteContact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

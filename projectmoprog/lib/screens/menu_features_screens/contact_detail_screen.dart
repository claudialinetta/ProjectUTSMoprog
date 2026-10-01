import 'package:flutter/material.dart';
import 'package:projectmoprog/models/contact_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'call_screen.dart';
import '../chat_screens/chat_screen.dart';
import '../../services/call_event_service.dart';

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
    _recordCheck();
  }

  Future<void> _recordCheck() async {
    final c = widget.contact;

    try {
      await _supabase.from('number_checks').insert({
        'owner_id': widget.currentUserId,
        'name': c.name,
        'phone_number': c.phoneNumber,
        'phone_key': c.phoneNumber.replaceAll(RegExp(r'\D'), ''),
        'checked_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to log number check: $e');
    }
  }

  Future<void> _deleteContact() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Contact',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Are you sure you want to delete this contact?',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.blue,
              ),
            ),
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

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color sheetBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color inputFillColor = isDark
        ? const Color(0xFF2C2C2C)
        : Colors.transparent;
    final Color borderColor = isDark
        ? const Color(0xFF424242)
        : Colors.grey.shade400;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
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
              Text(
                'Edit Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                  filled: isDark,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                  filled: isDark,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
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

                  String newInitial = '?';
                  final words = newName.split(RegExp(r'\s+'));
                  if (words.isNotEmpty && words[0].isNotEmpty) {
                    if (words.length == 1) {
                      newInitial = words[0][0].toUpperCase();
                    } else {
                      newInitial = (words[0][0] + words[1][0]).toUpperCase();
                    }
                  }

                  Navigator.pop(bottomSheetContext);

                  try {
                    await _supabase
                        .from('contacts')
                        .update({
                          'name': newName,
                          'phoneNumber': newPhone,
                          'avatarInitial': newInitial,
                        })
                        .eq('id', _currentContact.id);

                    setState(() {
                      _currentContact = ContactModel(
                        id: _currentContact.id,
                        name: newName,
                        phoneNumber: newPhone,
                        tag: _currentContact.tag,
                        reportCount: _currentContact.reportCount,
                        avatarInitial: newInitial,
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(45),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color screenBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F9);

    final Color dialogBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final Color shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: screenBgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: dialogBgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
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
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.grey.shade300 : Colors.grey,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isDark
                        ? Colors.blue.shade900
                        : Colors.blue.shade100,
                    child: Text(
                      _currentContact.avatarInitial,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.blue.shade100
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _currentContact.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentContact.phoneNumber,
                    style: TextStyle(fontSize: 18, color: subTextColor),
                  ),
                  const SizedBox(height: 48),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.chat_bubble_rounded,
                          label: 'Chat',
                          color: isDark
                              ? Colors.blue.shade400
                              : Colors.blue.shade600,
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
                        const SizedBox(width: 20),
                        _buildActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: isDark
                              ? Colors.orange.shade400
                              : Colors.orange.shade700,
                          onTap: _showEditForm,
                        ),
                        const SizedBox(width: 20),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          color: isDark ? Colors.red.shade400 : Colors.red,
                          onTap: _deleteContact,
                        ),
                        const SizedBox(width: 20),
                        _buildActionButton(
                          icon: Icons.call,
                          label: 'Call',
                          color: Colors.green,
                          onTap: () async {
                            final callService = CallEventService();

                            try {
                              final currentUser = await callService
                                  .getCurrentUser(widget.currentUserId);

                              if (currentUser == null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Current user could not be found.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final receiver = await callService
                                  .findUserByPhone(_currentContact.phoneNumber);

                              if (receiver == null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This number is not registered on GetContact.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final receiverId = receiver['id'].toString();

                              if (receiverId == widget.currentUserId) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'You cannot call your own number.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final event = await callService.createCall(
                                callerId: widget.currentUserId,
                                receiverId: receiverId,
                                callerName: currentUser['name'].toString(),
                                callerPhone: currentUser['phoneNumber']
                                    .toString(),
                              );

                              if (!mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CallScreen(
                                    contact: _currentContact,
                                    currentUserId: widget.currentUserId,
                                    callId: event['id'].toString(),
                                    isCaller: true,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to start call: $e'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

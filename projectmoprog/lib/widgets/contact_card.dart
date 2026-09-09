import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import 'tag_badge.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            contact.avatarInitial,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(contact.phoneNumber),
        trailing: TagBadge(tag: contact.tag),
      ),
    );
  }
}

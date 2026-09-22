import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../chat_screens/chat_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final ContactModel contact;
  final String currentUserId;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontak'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                contact.avatarInitial,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              contact.name,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              contact.phoneNumber,
              style: const TextStyle(
                fontSize: 18, 
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      contact: contact,
                      currentUserId: currentUserId,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.blue.shade600,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
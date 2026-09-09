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
  late Future<List<ContactModel>> _futureContacts;

  @override
  void initState() {
    super.initState();
    _futureContacts = _service.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GetContact Clone")),
      body: FutureBuilder<List<ContactModel>>(
        future: _futureContacts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snapshot.data ?? [];
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) =>
                ContactCard(contact: contacts[index]),
          );
        },
      ),
    );
  }
}

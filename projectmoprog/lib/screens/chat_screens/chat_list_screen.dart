import 'package:flutter/material.dart';
import '../../../services/contact_service.dart';
import '../../models/contact_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  const ChatListScreen({super.key, required this.currentUserId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ContactService _service = ContactService();
  List<Map<String, dynamic>> _recentChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  Future<void> _fetchChatHistory() async {
    final chats = await _service.getRecentChats(widget.currentUserId);
    setState(() {
      _recentChats = chats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat History"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              itemCount: _recentChats.length,
              itemBuilder: (context, index) {
                final chatData = _recentChats[index];
                final contactData = chatData['contacts'] ?? chatData;
                final contact = ContactModel.fromJson(contactData);
                final lastMessage = chatData['text'] ?? "Image/Sound Message";
                String timeString = "";
                if (chatData['timestamp'] != null) {
                  final timestamp = DateTime.parse(chatData['timestamp']).toLocal();
                  timeString = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(contact.avatarInitial),
                  ),
                  title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(timeString, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          contact: contact,
                          currentUserId: widget.currentUserId),
                      ),
                    );

                    _fetchChatHistory();

                  },
                );
              },
            ),
    );
  }
}
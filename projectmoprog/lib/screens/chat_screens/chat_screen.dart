import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../models/chat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final ContactModel contact;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.contact,
    required this.currentUserId
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;

  ChatMessageModel? _editingMessage;

  late final Stream<List<Map<String, dynamic>>> _chatStream;

  @override
  void initState() {
    super.initState();
    _chatStream = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('createdAt', ascending: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendOrUpdateMessage() async{
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final isEditing = _editingMessage != null;
    final editId = _editingMessage?.id;
    
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });

    try {
      if (isEditing) {
        await _supabase.from('messages').update({
          'content': text,
          'isEdited': true,
        }).eq('id', editId!);
      } else {
        await _supabase.from('messages').insert({
          'senderId': widget.currentUserId,
          'receiverId': widget.contact.phoneNumber,
          'content': text,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startEditing(ChatMessageModel message) {
    setState(() {
      _editingMessage = message;
      _messageController.text = message.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  Future<void> _deleteMessage(String id) async{
    if (_editingMessage?.id == id) {
      _cancelEditing();
    }
    
    try {
      await _supabase.from('messages').delete().eq('id', id);
    } catch (e) {
      debugPrint('Failed to delete message: $e');
    }
  }

  void _showMessageOptions(ChatMessageModel message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isMe) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _startEditing(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message.id);
                  },
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'You can only edit or delete your own messages.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 18,
              child: Text(
                widget.contact.avatarInitial,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.contact.phoneNumber,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final rawMessages = snapshot.data!.where((msg) {
                  final dbSender = msg['senderId'].toString();
                  final dbReceiver = msg['receiverId'].toString();
                  final myId = widget.currentUserId.toString();
                  final contactId = widget.contact.phoneNumber.toString();

                  final isMeSender = dbSender == myId && dbReceiver == contactId;
                  final isMeReceiver = dbSender == contactId && dbReceiver == myId;
                  return isMeSender || isMeReceiver;
                }).toList();

                final messages = rawMessages.map((msg) {
                  final model = ChatMessageModel(
                    id: msg['id'].toString(),
                    text: msg['content'] ?? '',
                    timestamp: msg['createdAt'] != null ? DateTime.parse(msg['createdAt']) : DateTime.now(),
                    isMe: msg['senderId'].toString() == widget.currentUserId.toString(),
                  );
                  model.isEdited = msg['isEdited'] == true;
                  return model;
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(message),
                      child: Align(
                        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: message.isMe ? Colors.blue.shade600 : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(message.isMe ? 16 : 2),
                              bottomRight: Radius.circular(message.isMe ? 2 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isMe ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (message.isEdited)
                                    Text(
                                      'Edited • ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: message.isMe ? Colors.white70 : Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  Text(
                                    _formatTime(message.timestamp.toLocal()),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: message.isMe ? Colors.white70 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (_editingMessage != null)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Editing message...',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: _cancelEditing,
                  )
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: _editingMessage != null ? 'Edit message...' : 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(
                      _editingMessage != null ? Icons.check : Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _sendOrUpdateMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
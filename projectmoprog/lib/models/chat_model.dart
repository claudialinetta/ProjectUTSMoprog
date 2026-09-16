class ChatMessageModel {
  final String id;
  String text;
  final DateTime timestamp;
  final bool isMe;
  bool isEdited;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.isEdited = false,
  });
}
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  final String currentUserId;

  const NotificationScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final data = await _notificationService.getNotifications(widget.currentUserId);
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead(widget.currentUserId);
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          ownerId: _notifications[i].ownerId,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          createdAt: _notifications[i].createdAt,
          isRead: true,
        );
      }
    });
  }

  Widget _getIconForType(String type) {
    switch (type) {
      case 'login':
        return CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.login, color: Colors.blue));
      case 'missed_call':
        return CircleAvatar(backgroundColor: Colors.red.shade100, child: const Icon(Icons.phone_missed, color: Colors.red));
      case 'spam_warning':
        return CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.warning_amber_rounded, color: Colors.orange));
      case 'new_contact':
        return CircleAvatar(backgroundColor: Colors.green.shade100, child: const Icon(Icons.person_add, color: Colors.green));
      default:
        return CircleAvatar(backgroundColor: Colors.grey.shade200, child: const Icon(Icons.notifications, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Read All', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(
              child: Text(
                'No Notification',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];

                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                  ),
                  onDismissed: (direction) {
                    _notificationService.deleteNotification(notif.id);
                    setState(() {
                      _notifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifikasi dihapus'), duration: Duration(seconds: 1)),
                    );
                  },
                
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: _getIconForType(notif.type),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            notif.message,
                            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                          ),
                        ),
                        onTap: () {
                          if (!notif.isRead) {
                            _notificationService.markAsRead(notif.id);
                            setState(() {
                              _notifications[index] = NotificationModel(
                                id: notif.id, ownerId: notif.ownerId, title: notif.title, 
                                message: notif.message, type: notif.type, createdAt: notif.createdAt, 
                                isRead: true,
                              );
                            });
                          }
                        },
                      ),
                  ),
                    
                );
              },
            ),
    );
  }
}
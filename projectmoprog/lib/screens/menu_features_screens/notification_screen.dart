import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../menu_tab_screen/account_settings_screen.dart';

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

  Widget _getIconForType(String type, bool isDark) {
    switch (type) {
      case 'birthday':
      return CircleAvatar(
        backgroundColor: isDark ? Colors.blueGrey.withValues(alpha: 0.2) : Colors.blueGrey.shade100,
        child: Icon(Icons.settings, color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey), 
      );
      case 'login':
        return CircleAvatar(
          backgroundColor: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade100, 
          child: Icon(Icons.login, color: isDark ? Colors.blue.shade300 : Colors.blue),
        );
      case 'missed_call':
        return CircleAvatar(
          backgroundColor: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade100, 
          child: Icon(Icons.phone_missed, color: isDark ? Colors.red.shade300 : Colors.red),
        );
      case 'spam_warning':
        return CircleAvatar(
          backgroundColor: isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange.shade100, 
          child: Icon(Icons.warning_amber_rounded, color: isDark ? Colors.orange.shade300 : Colors.orange),
        );
      case 'new_contact':
        return CircleAvatar(
          backgroundColor: isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade100, 
          child: Icon(Icons.person_add, color: isDark ? Colors.green.shade300 : Colors.green),
        );
      default:
        return CircleAvatar(
          backgroundColor: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200, 
          child: Icon(Icons.notifications, color: isDark ? Colors.grey.shade400 : Colors.grey),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Read All', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blue.shade400 : null,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Text(
                'No Notification',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey, 
                  fontSize: 16,
                ),
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
                      color: isDark ? Colors.red.shade700 : Colors.red,
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
                        color: isDark 
                            ? (notif.isRead ? const Color(0xFF1E1E1E) : Colors.blue.withValues(alpha: 0.15))
                            : (notif.isRead ? Colors.white : Colors.blue.shade50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: _getIconForType(notif.type, isDark),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            notif.message,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, 
                              height: 1.4,
                            ),
                          ),
                        ),
                        onTap: () async{
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

                          if (notif.type == 'birthday') {
                          final isDone = await _notificationService.isBirthdayCompleted(widget.currentUserId);

                          if (isDone) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anda sudah pernah mengatur tanggal lahir.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          await _notificationService.setBirthdayCompleted(widget.currentUserId);

                          if (!context.mounted) return;

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountSettingsScreen(
                                initialName: '',
                                phoneNumber: widget.currentUserId,
                                initialDateOfBirth: null,
                              ),
                            ),
                          );
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
